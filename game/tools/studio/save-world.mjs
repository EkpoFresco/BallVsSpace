// Capture intentional Edit-mode geometry changes into the canonical Rojo world asset.
import {mkdirSync, writeFileSync} from 'node:fs';
import path from 'node:path';
import {gameRoot} from '../lib/project.mjs';
import {callStudio} from './client.mjs';
const studio = process.argv[2];
if (!studio) throw Error('Explicit verified local Studio ID required');
const result = callStudio(studio, 'execute_luau', {datamodel_type:'Edit', code:`
assert(game.PlaceId==0 and not game:GetService('RunService'):IsRunning(), 'Local Edit mode required')
local world=assert(workspace:FindFirstChild('BVSCourt'), 'Authored world missing')
for _,n in world:GetDescendants() do assert(not n:IsA('LuaSourceContainer'), 'World asset must not contain scripts') end
local bytes=game:GetService('SerializationService'):SerializeInstancesAsync({world})
local hex=table.create(buffer.len(bytes))
for i=0,buffer.len(bytes)-1 do hex[i+1]=string.format('%02x',buffer.readu8(bytes,i)) end
return {hex=table.concat(hex),descendants=#world:GetDescendants()}
`});
if (!/^(?:[0-9a-f]{2})+$/.test(result.hex)) throw Error('Invalid serialized world');
const directory = path.join(gameRoot, 'assets/world');
mkdirSync(directory, {recursive:true});
writeFileSync(path.join(directory,'Lobby.rbxm'), Buffer.from(result.hex, 'hex'));
console.log(`Saved authored lobby: ${result.descendants} descendants.`);
