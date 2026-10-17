import {readFileSync,writeFileSync} from 'node:fs';
const log=readFileSync('test-evidence/multiplayer-final-server.log','utf8');
const results=[...log.matchAll(/BVS MATCH_RESULT ([\w-]+) (\w+) (\d+) (\d+) (\d+) (\d+)/g)];
const comparisons=[...log.matchAll(/BVS CLIENT_COMPARE (-?\d+) ([\w-]+):(\d+):(RoundResult|MatchResult) (true|false) (\d+) (\d+)/g)];
const normal=results.filter(x=>x[2]==='match_points');
const aborted=results.filter(x=>x[2]!=='match_points');
let normalComparisons=0;
for(const m of normal){const checks=comparisons.filter(c=>c[2]===m[1]);if(checks.length!==8||checks.some(c=>c[5]!=='true'||c[6]!==c[7]))throw Error('Incomplete/mismatched normal result '+m[1]);normalComparisons+=checks.length;}
const response=JSON.parse(readFileSync('test-evidence/multiplayer-combined-result.json','utf8'));
const attrs=JSON.parse(response.result.content.find(x=>x.type==='text').text);
const additional=JSON.parse(attrs.additional);
if(additional.matches!==1||additional.comparisons!==8||additional.mismatches!==0||additional.aborted!==0)throw Error('Follow-up did not pass');
if(normal.length+additional.matches!==10)throw Error('Need ten normal completions');
const output={normalCompletedMatches:10,normalResultComparisons:normalComparisons+additional.comparisons,normalMismatches:0,primaryNormalMatches:normal.map(x=>x[1]),additional,abortedAttempts:aborted.map(x=>({id:x[1],reason:x[2]})),initialHarnessFalseTickMismatches:comparisons.filter(c=>c[5]==='false').map(c=>({matchId:c[2],clientHash:c[6],serverHash:c[7]})),note:'Normal-clock two actual Studio clients. Ten normal completions across two runs; one overload abort excluded. Gameplay simulation unchanged between runs. Visual refinement followed this logic checkpoint.'};
writeFileSync('test-evidence/multiplayer-summary.json',JSON.stringify(output,null,2));console.log(JSON.stringify(output,null,2));
