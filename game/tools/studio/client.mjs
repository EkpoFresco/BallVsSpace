import { mkdtempSync, readFileSync, writeFileSync, unlinkSync, rmdirSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { decodeResponse, outputFile } from '../lib/project.mjs';

export function callStudio(studio, name, args = {}, output) {
  if (typeof studio !== 'string' || !studio.trim()) {
    throw Error('Explicit verified Studio ID required');
  }
  const temp = mkdtempSync(path.join(tmpdir(), 'bvs-studio-'));
  const request = path.join(temp, 'request.json');
  try {
    writeFileSync(request, JSON.stringify({ name, arguments: { ...args, studio_id: studio } }));
    const command = [path.join(import.meta.dirname, 'studio-mcp.mjs'), 'call', request];
    if (output) command.push(output);
    const run = spawnSync(process.execPath, command, {
      encoding: 'utf8', windowsHide: true, maxBuffer: 4 * 1024 * 1024, timeout: 125000,
    });
    if (run.error) throw run.error;
    if (run.status !== 0) throw Error(run.stdout + run.stderr);
    return decodeResponse(JSON.parse(output ? readFileSync(output, 'utf8') : run.stdout));
  } finally {
    if (existsSync(request)) unlinkSync(request);
    rmdirSync(temp);
  }
}

export function createQa(studio, prefix) {
  outputFile(prefix + '.json');
  let sequence = 0;
  return (name, args, label) => {
    const safeLabel = String(label).replace(/[^A-Za-z0-9_.-]+/g, '-');
    const output = outputFile(`${prefix}-${String(++sequence).padStart(2, '0')}-${safeLabel}.json`);
    const result = callStudio(studio, name, args, output);
    console.log(label, output);
    return result;
  };
}
