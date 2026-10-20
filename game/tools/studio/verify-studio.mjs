import {sourceInventory,luauString as quote,outputFile} from '../lib/project.mjs';
import {callStudio} from './client.mjs';
const studio=process.argv[2];if(!studio)throw Error('Explicit verified Studio ID required');
const files=sourceInventory(),code=['assert(game.PlaceId==0,"Wrong place")','assert(game:GetService("StarterGui").ScreenOrientation==Enum.ScreenOrientation.LandscapeSensor,"Landscape orientation mismatch")'];
for(const f of files){
 let expression=`game:GetService(${quote(f.parts[0])})`;
 for(const part of f.parts.slice(1))expression+=`:FindFirstChild(${quote(part)})`;
 code.push(`assert(${expression}.Source==${quote(f.source)},${quote('Source mismatch: '+f.parts.join('.'))})`);
}
code.push(`return {verifiedSourceFiles=${files.length},placeId=game.PlaceId,gameId=game.GameId,streaming=workspace.StreamingEnabled}`);
console.log(callStudio(studio,'execute_luau',{datamodel_type:'Edit',code:code.join('\n')},outputFile('source-consistency.json')));
