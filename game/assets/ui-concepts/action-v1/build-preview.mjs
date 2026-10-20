import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

// Reproduce the design discussion fragment; this is not a game/runtime build.
const directory = path.dirname(fileURLToPath(import.meta.url));
const destination = process.argv[2];
if (!destination) throw new Error('Pass an absolute output .html path.');
if (!path.isAbsolute(destination)) throw new Error('Output path must be absolute.');
const data = JSON.parse(await fs.readFile(path.join(directory, 'preview-data.json'), 'utf8'));
const dataUrl = async (file, type) => `data:${type};base64,${(await fs.readFile(path.join(directory, file))).toString('base64')}`;
const replacements = {
  __FONT_LICENSE__: await fs.readFile(path.join(directory, 'fonts/Montserrat-OFL.txt'), 'utf8'),
  __DISPLAY_FONT__: await dataUrl('fonts/Montserrat-BlackItalic.ttf', 'font/ttf'),
  __BODY_FONT__: await dataUrl('fonts/Montserrat-Regular.ttf', 'font/ttf'),
  __BALLS__: await dataUrl('../../art/balls.png', 'image/png'),
  __ICONS__: await dataUrl('../../art/icons.svg', 'image/svg+xml'),
  __ENTRIES__: JSON.stringify(data.entries),
  __ICON_POSITIONS__: JSON.stringify(data.icons),
};
let html = await fs.readFile(path.join(directory, 'preview.template.html'), 'utf8');
for (const [placeholder, value] of Object.entries(replacements)) html = html.replace(placeholder, () => value);
if (/__[A-Z_]+__/.test(html)) throw new Error('Unresolved template placeholder.');
if (Buffer.byteLength(html) >= 1_000_000) throw new Error('Fragment exceeds 1 MB.');
if (/<\/?(?:html|head|body)\b|<!doctype/i.test(html)) throw new Error('Expected a fragment.');
new vm.Script(html.match(/<script>([\s\S]*?)<\/script>/)[1]);
await fs.writeFile(destination, html);
console.log(JSON.stringify({ output: destination, bytes: Buffer.byteLength(html), syntax: 'passed' }));
