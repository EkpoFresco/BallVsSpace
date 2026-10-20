const sourcePage=await figma.getNodeByIdAsync('0:1');
await figma.loadFontAsync({family:'Montserrat',style:'Black Italic'});
await figma.loadFontAsync({family:'Montserrat',style:'Regular'});
const primary=await figma.getNodeByIdAsync('8:28'), secondary=await figma.getNodeByIdAsync('8:31');
const vars=await figma.variables.getLocalVariablesAsync('COLOR');
const byName=Object.fromEntries(vars.map(v=>[v.name,v]));
const styles=await figma.getLocalTextStylesAsync();
let page=figma.root.children.find(p=>p.name==='02 — Action theme · Full game');
if(page)throw Error('Expansion page already exists; inspect before retry');
page=figma.createPage();page.name='02 — Action theme · Full game';await figma.setCurrentPageAsync(page);
const ids=[page.id],screens=[];
function track(n){ids.push(n.id);return n}
function fill(k){return [figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color',byName['primitive/'+k])]}
function frame(p,name,w,h,bg,axis){let n=track(figma.createFrame());n.name=name;n.resize(w,h);n.fills=bg?fill(bg):[];if(axis){n.layoutMode=axis;n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED'}p.appendChild(n);return n}
function txt(p,value,size=14,display=false,color='text',w){let n=track(figma.createText());n.name=value.slice(0,36);n.fontName={family:'Montserrat',style:display?'Black Italic':'Regular'};n.fontSize=size;n.characters=value;n.fills=fill(color);n.lineHeight={unit:'PERCENT',value:120};p.appendChild(n);if(w){n.resize(w,n.height);n.textAutoResize='HEIGHT'}return n}
function pos(n,x,y){if(n.parent.layoutMode&&n.parent.layoutMode!=='NONE')n.layoutPositioning='ABSOLUTE';n.x=x;n.y=y;return n}
function rect(p,x,y,w,h,k){return pos(frame(p,'Graphic',w,h,k),x,y)}
function action(p,label,x,y,w=160,kind='primary'){let n=track((kind==='primary'?primary:secondary).createInstance());p.appendChild(n);n.resize(w,44);n.findOne(i=>i.name==='Label').characters=label;return pos(n,x,y)}
const balls=['Verity','Axe','Poison','Burst','Cell','Vampire','Acid','Blade','WDC','Orbit','Ray','Laser'];
const icons=['Heart','Gear','Coin','Gem','Store','Inventory','Emote','Gift','Invite','Trade','Quest','Reroll','Crown','Close','Help','Chat','Events','Fusion','Axe','Blade','Ufo','Explosion','Parasol','Balloons','Check','Back','Arrow','Sound','Diamond','Ring','Spark','Shadow'];
function sprite(p,name,x,y,size,ball=true){let i=(ball?balls:icons).indexOf(name),cols=ball?4:8,rows=ball?3:4;let n=frame(p,name+' · canonical art',size,size);n.clipsContent=true;pos(n,x,y);let r=track(figma.createRectangle());r.resize(size*cols,size*rows);r.fills=[{type:'IMAGE',imageHash:ball?'731495e9a50b3028028f1151f88d71abe6a58176':'9b4b5e216e62f6a626b7e0a0873aef085eb80677',scaleMode:'FILL'}];n.appendChild(r);r.x=-(i%cols)*size;r.y=-Math.floor(i/cols)*size;return n}
const header=track(figma.createComponent());header.name='BVS / Action header';header.resize(500,56);header.fills=fill('headerDark');header.clipsContent=true;page.appendChild(header);header.x=2800;header.y=100;header.description='Shared crimson title band for utilities, draft and results. Montserrat Black Italic; same action-v1 tokens.';
for(let i=0;i<5;i++){let r=rect(header,40+i*120,-35,30,140,'text');r.rotation=28;r.opacity=.10}
pos(txt(header,'SCREEN TITLE',28,true),18,12);
function heading(p,title,w){let n=track(header.createInstance());p.appendChild(n);n.resize(w,56);n.findOne(i=>i.type==='TEXT').characters=title.toUpperCase();return n}
function screen(name,x,y,w=803,h=602){let n=frame(page,name,w,h,'ink');pos(n,x,y);n.strokes=fill('line');n.strokeWeight=1;screens.push({id:n.id,name,width:w,height:h});return n}
let lobby=screen('Lobby · Action theme',100,100);pos(txt(lobby,'BALL VS SPACE',28,true),250,45);pos(txt(lobby,'CHOOSE A LOOK. CLAIM THE ARENA.',12,false,'secondary'),255,84);
for(let i=0;i<3;i++){let id=['Store','Inventory','Emote'][i];let f=rect(lobby,24,150+i*90,100,78,'card');sprite(f,id,35,5,30,false);pos(txt(f,id==='Emote'?'EMOTES':id.toUpperCase(),12,true),12,48)}
let quest=rect(lobby,570,30,210,155,'surface');heading(quest,'Practice quests',210);['Choose a ball','Lock your aim','Win a round'].forEach((s,i)=>pos(txt(quest,s+'   0/1',12),12,65+i*25));
action(lobby,'PRACTICE',500,525,164);action(lobby,'PLAY',315,525,175);action(lobby,'1V1',205,525,95,'secondary');action(lobby,'INVITE',632,435,147,'secondary');sprite(lobby,'Gear',195,25,36,false);sprite(lobby,'Gift',145,25,36,false);
sprite(lobby,'Verity',220,210,150);sprite(lobby,'Axe',420,210,150);pos(txt(lobby,'Every ball is yours to explore.',15,false,'secondary'),273,405);
let draft=screen('Draft · Choose your ball',950,100);pos(heading(draft,'Choose your ball — 12',512),145,120);
for(let i=0;i<3;i++){let f=rect(draft,160+i*175,194,132,212,'card');pos(txt(f,['Cell Ball','Axe Ball','Poison Spike Ball'][i],i===2?14:20,true,'text',120),6,12);rect(f,28,52,76,76,'paper');sprite(f,['Cell','Axe','Poison'][i],12,42,108);pos(txt(f,['Pulse outward.\nClaim nearby space.','Spin an axe.\nWiden your territory.','A bright shell.\nA powerful pulse.'][i],14,false,'secondary',120),6,143)}
action(draft,'ALL BALLS',300,438,180);action(draft,'REROLL',492,438,132,'secondary');
let battle=screen('Match HUD · Aim and territory',1800,100);pos(txt(battle,'ADJUST YOUR AIM — 12',24,true),215,12);rect(battle,145,60,512,510,'surface');rect(battle,178,93,446,446,'card');
for(let i=0;i<20;i++){let r=rect(battle,178+(i%5)*22,93+Math.floor(i/5)*22,22,22,'accent');r.opacity=.30+i%3*.15}
sprite(battle,'Acid',220,255,84);sprite(battle,'Axe',505,330,84);pos(txt(battle,'YOU',16,true,'accent'),35,100);pos(txt(battle,'OPPONENT',13,true),670,100);for(let i=0;i<3;i++){sprite(battle,'Heart',25+i*30,140,25,false);sprite(battle,'Heart',674+i*30,140,25,false)}action(battle,'LOCK AIM',324,457,155);pos(txt(battle,'25.3%     ◇        0 — 0        ○     22.4%',16,true),220,548);
let result=screen('Results · Victory, defeat and draw',100,760);let resultPanel=rect(result,200,108,403,395,'surface');heading(resultPanel,'Match complete',403);sprite(resultPanel,'Crown',145,70,110,false);pos(txt(resultPanel,'VICTORY!',34,true),100,190);pos(txt(resultPanel,'43.9% — 37.7%',20,true),110,260);pos(txt(resultPanel,'More territory. Match won.',14,false,'secondary'),100,305);action(result,'REMATCH',324,517,155);
let picker=screen('All Balls · Draft picker',950,760);let pick=rect(picker,52,51,700,500,'surface');heading(pick,'Select any ball — 12',700);for(let i=0;i<12;i++){let f=rect(pick,12+(i%4)*172,64+Math.floor(i/4)*119,160,108,'card');sprite(f,balls[i],45,0,72);pos(txt(f,balls[i],12,false,'text',140),10,82)}action(pick,'NO',12,446,330,'secondary');action(pick,'YES',354,446,330);
function modal(name,x,y,w,h){let n=screen(name,x,y,w,h);heading(n,name,w);sprite(n,'Close',w-52,6,44,false);return n}
let settings=modal('View settings',1800,760,500,300);action(settings,'TERRITORY OVERLAY: ON',24,94,452,'secondary');action(settings,'REDUCED MOTION: OFF',24,168,452,'secondary');
let rewards=modal('Rewards',100,1420,420,340);sprite(rewards,'Gift',168,72,84,false);pos(txt(rewards,'Your collection starts here',22,true,'text',370),25,172);pos(txt(rewards,'Explore every look and take it into the arena.',15,false,'secondary',360),30,218);action(rewards,'EXPLORE BALLS',98,285,224);
let modes=modal('Play',560,1420,460,326);for(let i=0;i<2;i++){let f=rect(modes,24+i*218,80,194,175,'card');sprite(f,i?'Verity':'Axe',42,5,110);action(f,i?'PRACTICE':'1V1',10,125,174)}pos(txt(modes,'Choose a duel or warm up with Practice.',13,false,'secondary'),38,282);
let help=modal('How to play',1060,1420,500,370);[['Choose your ball','Pick a look and a territory kit.'],['Set your direction','Aim on the court, then lock it in.'],['Claim more space','More owned area wins.']].forEach((v,i)=>{let r=rect(help,20,71+i*77,460,65,'card');pos(txt(r,String(i+1),30,true,'accent'),15,12);pos(txt(r,v[0],19,true),65,4);pos(txt(r,v[1],13,false,'secondary'),65,36)});pos(txt(help,'Brighter tiles are reinforced. Repaint to take control.',13,false,'secondary',456),22,313);
let trade=modal('Trade',1600,1420,460,340);sprite(trade,'Trade',183,74,94,false);pos(txt(trade,'Your collection, shared',24,true,'text',410),25,186);pos(txt(trade,'Trading is not available yet.\nEvery current ball is free in Inventory.',16,false,'secondary',400),30,233);
let emotes=modal('Emotes',2100,1420,440,306);['Wave','Cheer','Dance','Laugh'].forEach((v,i)=>{let b=action(emotes,v.toUpperCase(),19+(i%2)*209,90+Math.floor(i/2)*100,193,'secondary');sprite(emotes,'Emote',32+(i%2)*209,90+Math.floor(i/2)*100,30,false)});
let invite=modal('Invite friends',1800,1100,500,270);sprite(invite,'Invite',28,96,82,false);pos(txt(invite,'A friendly rivalry starts with a duel.',17,false,'secondary',330),130,100);action(invite,'INVITE FRIENDS',130,175,330);
return {pageId:page.id,screens,headerComponent:header.id,createdOrMutatedIds:ids,variablesBound:vars.length,reusedComponents:['8:28','8:31']};
