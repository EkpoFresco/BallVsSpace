// Independent copies of the pinned runtime and approved inputs; never overwrite a route.
import { createHash } from 'node:crypto';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const repo = path.resolve(import.meta.dirname, '../../..');
const target = path.join(repo, 'game/assets/ui-concepts/action-v1');
const pilot = JSON.parse(readFileSync(path.join(target, 'pilot.json'), 'utf8'));
const destination = path.join(repo, 'game/pilots/action-v1');
if (existsSync(destination)) throw Error('Pilot workspace exists. Preserve its work; do not rerun setup over it.');
const sha256 = data => createHash('sha256').update(data).digest('hex');
const run = (command, args, cwd = repo) => {
  const result = spawnSync(command, args, { cwd, encoding: 'utf8', windowsHide: true, maxBuffer: 8 * 1024 * 1024 });
  if (result.error) throw result.error;
  if (result.status !== 0) throw Error(`${command} failed: ${result.stdout}\n${result.stderr}`);
  return (result.stdout + result.stderr).trim();
};
function inventory(root) {
  const files = [];
  function visit(directory, prefix = '') {
    for (const entry of readdirSync(directory, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const relative = prefix + entry.name;
      const absolute = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(absolute, relative + '/');
      else if (entry.isFile()) {
        const data = readFileSync(absolute);
        files.push({ path: relative, bytes: data.length, sha256: sha256(data) });
      } else throw Error(`Unexpected link or special file: ${absolute}`);
    }
  }
  visit(root);
  return files;
}

const commit = run('git.exe', ['rev-parse', '--verify', `${pilot.baselineCommit}^{commit}`]);
if (commit !== pilot.baselineCommit) throw Error('Pinned baseline did not resolve exactly');
const inputFiles = inventory(target);
const sections = [
  'rokit.toml', '.gitattributes', 'game/.luaurc', 'game/selene.toml', 'game/stylua.toml',
  'game/default.project.json', 'game/src', 'game/assets/art', 'game/assets/runtime', 'game/tools',
];
mkdirSync(destination, { recursive: true });
const baseline = path.join(destination, 'baseline');
mkdirSync(baseline);
const zip = path.join(destination, 'baseline.zip');
run('git.exe', ['archive', '--format=zip', `--output=${zip}`, commit, '--', ...sections]);
const psQuote = value => "'" + value.replaceAll("'", "''") + "'";
run('powershell.exe', ['-NoProfile', '-NonInteractive', '-Command',
  `Expand-Archive -LiteralPath ${psQuote(zip)} -DestinationPath ${psQuote(baseline)}`]);
cpSync(target, path.join(baseline, 'game/assets/ui-concepts/action-v1'), { recursive: true, errorOnExist: true, force: false });
const referenceRoot = path.join(baseline, 'game/assets/ui-concepts/research-reset');
mkdirSync(referenceRoot, { recursive: true });
for (const name of ['user-action-ui-reference.png', 'research.json']) {
  cpSync(path.join(target, '../research-reset', name), path.join(referenceRoot, name), { errorOnExist: true, force: false });
}
const files = inventory(baseline);
const manifestSha256 = sha256(JSON.stringify(files));
const preview = path.join(destination, 'approved-preview.html');
run(process.execPath, [path.join(target, 'build-preview.mjs'), preview]);
const previewSha256 = sha256(readFileSync(preview));
if (previewSha256 !== pilot.approvedPreviewSha256) throw Error('Approved preview changed; do not start routes');

const result = {
  schemaVersion: 1, preparedAtUtc: new Date().toISOString(), baselineCommit: commit,
  scope: pilot.scope, destination: path.relative(repo, destination).replaceAll('\\', '/'),
  source: 'Git archive of pinned runtime/tooling/assets plus unchanged approved inputs. Independent copies, no hardlinks or shared mutable source.',
  archivedPaths: sections, approvedInputs: inputFiles,
  approvedPreviewSha256: previewSha256, commonManifestSha256: manifestSha256, commonFileCount: files.length,
  runtimeSourceCount: files.filter(f => f.path.startsWith('game/src/') && f.path.endsWith('.luau')).length,
  tools: {}, routes: {}, limits: ['Setup/build checks only; no route implementation or new gameplay acceptance.'],
};
for (const executable of ['git.exe', 'rojo.exe', 'rokit.exe', 'stylua.exe', 'selene.exe', 'luau-lsp.exe']) {
  result.tools[executable] = run(executable, ['--version']);
}
result.tools.node = process.version;
for (const route of ['A', 'B', 'C']) {
  const root = path.join(destination, 'routes', route);
  cpSync(baseline, root, { recursive: true, errorOnExist: true, force: false });
  if (sha256(JSON.stringify(inventory(root))) !== manifestSha256) throw Error(`Route ${route} copy differs`);
  const buildDir = path.join(root, 'game/builds');
  mkdirSync(buildDir);
  const builds = [];
  for (const extension of ['rbxl', 'rbxlx']) {
    const name = `BallVsSpace.${extension}`;
    const log = run('rojo.exe', ['build', 'default.project.json', '-o', `builds/${name}`], path.join(root, 'game'));
    writeFileSync(path.join(buildDir, `${extension}.log`), log + '\n');
    const bytes = readFileSync(path.join(buildDir, name));
    builds.push({ file: `game/builds/${name}`, bytes: bytes.length, sha256: sha256(bytes) });
  }
  result.routes[route] = { path: path.relative(repo, root).replaceAll('\\', '/'), status: 'ready; implementation not started', initialManifestSha256: manifestSha256, builds };
  mkdirSync(path.join(root, 'pilot-log'));
  writeFileSync(path.join(root, 'pilot-log/events.jsonl'), '');
  writeFileSync(path.join(root, 'pilot-log/README.md'), `# Route ${route}\n\n${pilot.routes[route]}\n\nStart from this workspace only. Log start/end UTC, phase, result, manual interventions and available cost in events.jsonl. Unknown cost stays unknown. Count route-specific preparation as well as translation, implementation and debugging. No implementation time has been recorded yet.\n`);
}
for (const index of [0, 1]) {
  if (new Set(Object.values(result.routes).map(route => route.builds[index].sha256)).size !== 1) throw Error('Equivalent route builds differ');
}
if (JSON.stringify(inventory(target)) !== JSON.stringify(inputFiles)) throw Error('Approved inputs changed during setup');
writeFileSync(path.join(destination, 'baseline-manifest.json'), JSON.stringify(files, null, 2) + '\n');
writeFileSync(path.join(destination, 'setup.json'), JSON.stringify(result, null, 2) + '\n');
console.log(JSON.stringify(result, null, 2));
