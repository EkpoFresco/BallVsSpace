// Real Studio input plus an independent check that visible painted cells agree with the score.
import {readFileSync, writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio = process.argv[2];
if (!studio) throw Error('Explicit verified Studio ID required');
let sequence = 0;
function rpc(name, args, label) {
  const request = 'tools/handoff-ui-request.json';
  const output = `test-evidence/handoff-ui-${String(++sequence).padStart(2, '0')}-${label}.json`;
  writeFileSync(request, JSON.stringify({name, arguments: {studio_id: studio, ...args}}));
  const run = spawnSync(process.execPath, ['tools/studio-mcp.mjs', 'call', request, output], {encoding: 'utf8', windowsHide: true});
  if (run.status) throw Error(run.stdout + run.stderr);
  console.log(label, output);
  const result = JSON.parse(readFileSync(output, 'utf8')).result;
  const text = result.content.find(x => x.type === 'text')?.text;
  try { return JSON.parse(text); } catch { return text; }
}
const gui = 'game:GetService("Players").LocalPlayer.PlayerGui';
const code = (text, label) => rpc('execute_luau', {datamodel_type: 'Client', code: text}, label);
const click = (path, label) => rpc('user_mouse_input', {datamodel_type: 'Client', actions: [{action: 'mouseButtonClick', mouse_button: 'left', instance_path: 'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.' + path}]}, label);
const capture = label => rpc('screen_capture', {capture_id: label}, label);
function waitFor(phases, seconds) {
  const allowed = '{' + phases.map(x => JSON.stringify(x)).join(',') + '}';
  const phase = code(`local g=${gui}.BallVsSpace; local limit=os.clock()+${seconds}; repeat task.wait(.1) until table.find(${allowed},g:GetAttribute("Phase")) or os.clock()>limit; return g:GetAttribute("Phase")`, 'wait-phase');
  if (!phases.includes(phase)) throw Error('Unexpected phase: ' + phase);
}
waitFor(['Lobby'], 15);
code(`local r=${gui}.BallVsSpace.ReferenceCanvas; assert(r.Settings.Text==""); assert(r.Settings:FindFirstChild("GearIcon")); assert(r.Currency.Gem:FindFirstChild("TopRight")); assert(r.SettingsPanel.Territory.Text=="Territory overlay: ON"); return {defaultTerritory=true, authoredSymbols=true}`, 'default-and-symbols');
capture('lobby');
click('Settings', 'open-settings');
click('SettingsPanel.Territory', 'territory-off');
code(`local r=${gui}.BallVsSpace.ReferenceCanvas; assert(r.SettingsPanel.Visible); assert(r.SettingsPanel.Territory.Text=="Territory overlay: OFF"); return true`, 'off-confirmed');
click('SettingsPanel.Territory', 'territory-on');
code(`assert(${gui}.BallVsSpace.ReferenceCanvas.SettingsPanel.Territory.Text=="Territory overlay: ON"); return true`, 'on-confirmed');
click('Settings', 'close-settings');
click('Controls.Right', 'practice');
waitFor(['Draft'], 15);
click('Draft.Axe', 'choose-axe');
waitFor(['Aim'], 12);
code(`local p=${gui}; local r=p.BallVsSpace.ReferenceCanvas; assert(p.BVSTerritory.Enabled); assert(r.ScoreA.Visible and r.ScoreB.Visible); assert(r.PlayerSide1.Heart:FindFirstChild("Silhouette")); return {visibleTerritory=true, visibleScores=true}`, 'aim-default-visible');
capture('aim');
click('Controls.Primary', 'lock-aim');
waitFor(['Battle'], 10);
code('task.wait(7); return true', 'paint-progress');
const painting = code(`local p=${gui}; local r=p.BallVsSpace.ReferenceCanvas; local a,b=0,0; for _,tile in p.BVSTerritory.ReferenceCanvas:GetChildren() do if tile:IsA("Frame") and tile.Name:match("^Cell%d+$") and tile.BackgroundTransparency<1 then if tile.BackgroundColor3.B>tile.BackgroundColor3.R then a+=1 else b+=1 end end end; assert(a>0 and b>0,"Both teams must paint"); local shownA=tonumber(r.ScoreA.Text:match("([%d%.]+)%%")); local shownB=tonumber(r.ScoreB.Text:match("([%d%.]+)%%")); assert(shownA==tonumber(string.format("%.1f",a/10.24)),"Visible cyan cells disagree with score"); assert(shownB==tonumber(string.format("%.1f",b/10.24)),"Visible coral cells disagree with score"); return {cyanCells=a,coralCells=b,cyanPercent=shownA,coralPercent=shownB,phase=p.BallVsSpace:GetAttribute("Phase"),passed=true}`, 'paint-score-agreement');
capture('territory-battle');
waitFor(['RoundResult', 'MatchResult'], 30);
capture('round-result');
const result = code('return {tick=workspace:GetAttribute("BVSTick"),reason=workspace:GetAttribute("BVSResultReason"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB")}', 'outcome');
writeFileSync('test-evidence/handoff-ui-result.json', JSON.stringify({painting, result, checks: ['default-on', 'settings-off-on', 'authored-symbols', 'aim-scores-visible', 'paint-score-agreement', 'round-result']}, null, 2));
rpc('get_console_output', {}, 'console');
