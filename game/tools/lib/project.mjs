import { readFileSync, readdirSync, mkdirSync } from 'node:fs';
import path from 'node:path';

export const gameRoot = path.resolve(import.meta.dirname, '../..');
export const repoRoot = path.dirname(gameRoot);
export const evidenceRoot = path.join(gameRoot, 'test-evidence');
export const runRoot = path.join(evidenceRoot, 'runs');

export function outputFile(name) {
  if (!/^[A-Za-z0-9][A-Za-z0-9_.-]*$/.test(name) || name.includes('..')) {
    throw Error('Use a plain evidence filename');
  }
  mkdirSync(runRoot, { recursive: true });
  return path.join(runRoot, name);
}

export function luauString(value) {
  let equal = '';
  while (value.includes(']' + equal + ']')) equal += '=';
  return '[' + equal + '[' + value + ']' + equal + ']';
}

export function sourceInventory() {
  const files = [];
  function scan(relative, parts) {
    const entries = readdirSync(path.join(gameRoot, relative), { withFileTypes: true });
    for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
      const file = relative + '/' + entry.name;
      if (entry.isDirectory()) {
        scan(file, [...parts, entry.name]);
      } else if (entry.name.endsWith('.luau')) {
        files.push({
          file: path.join(gameRoot, file),
          relative: file,
          parts: [...parts, entry.name.replace(/\.(server|client)\.luau$|\.luau$/, '')],
          cls: entry.name.endsWith('.server.luau') ? 'Script'
            : entry.name.endsWith('.client.luau') ? 'LocalScript' : 'ModuleScript',
          source: readFileSync(path.join(gameRoot, file), 'utf8'),
        });
      }
    }
  }
  scan('src/shared', ['ReplicatedStorage', 'Shared']);
  scan('src/server', ['ServerScriptService', 'Server']);
  scan('src/client', ['StarterPlayer', 'StarterPlayerScripts', 'Client']);
  return files;
}

export function decodeResponse(response) {
  if (response.error || response.result?.isError) {
    throw Error(JSON.stringify(response.error ?? response.result));
  }
  const text = response.result?.content?.find(item => item.type === 'text')?.text;
  if (text === undefined) return response.result;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}
