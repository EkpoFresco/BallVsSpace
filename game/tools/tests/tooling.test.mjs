import test from 'node:test';import assert from 'node:assert/strict';
import {decodeResponse,luauString,sourceInventory,outputFile} from '../lib/project.mjs';

test('MCP transport and nested tool failures are rejected',()=>{
 assert.throws(()=>decodeResponse({error:{message:'transport failed'}}));
 assert.throws(()=>decodeResponse({result:{isError:true,content:[{type:'text',text:'failed'}]}}));
 assert.deepEqual(decodeResponse({result:{content:[{type:'text',text:'{"passed":true}'}]}}),{passed:true});
 assert.equal(decodeResponse({result:{content:[{type:'text',text:'plain output'}]}}),'plain output');
});
test('Luau source quoting survives embedded long-string delimiters',()=>{
 const source='return [[a]] .. [=[b]=] .. [====[c]====]';
 const quoted=luauString(source),opening=quoted.match(/^\[(=*)\[/)[1];
 assert(!source.includes(']'+opening+']'));assert.equal(quoted.slice(opening.length+2,-opening.length-2),source);
});
test('Evidence filenames cannot escape the run directory',()=>{
 for(const name of ['../secret','../../file','C:/file','a/b','a\\b','..'])assert.throws(()=>outputFile(name));
 assert.match(outputFile('run-01.json'),/runs[\\/]run-01\.json$/);
});
test('Shared inventory maps each canonical script once to its Rojo instance',()=>{
 const files=sourceInventory();assert.equal(files.length,42);assert.equal(new Set(files.map(f=>f.parts.join('.'))).size,files.length);
 assert(files.every(f=>f.source.startsWith('--!strict')));
 assert.equal(files.find(f=>f.relative==='src/client/Bootstrap.client.luau').cls,'LocalScript');
 assert.equal(files.find(f=>f.relative==='src/server/Bootstrap.server.luau').cls,'Script');
});
