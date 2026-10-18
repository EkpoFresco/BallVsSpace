import {Resvg} from '@resvg/resvg-js';
import {mkdirSync,writeFileSync} from 'node:fs';
import path from 'node:path';
const out=path.resolve(import.meta.dirname,'../../assets/art');mkdirSync(out,{recursive:true});
const svg=(content,w,h)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${content}</svg>`;
const pathTag=(d,fill='#fff',extra='')=>`<path d="${d}" fill="${fill}" ${extra}/>`;
const circle=(cx,cy,r,fill,extra='')=>`<circle cx="${cx}" cy="${cy}" r="${r}" fill="${fill}" ${extra}/>`;
const icons={
 Heart:pathTag('M32 57C20 49 4 36 4 21C4 5 24 3 32 16C40 3 60 5 60 21C60 36 44 49 32 57','#ed294b'),
 Gear:pathTag('M26 3H38L40 11L46 14L54 11L60 21L54 27V36L60 42L54 53L46 50L40 53L38 61H26L24 53L18 50L10 53L4 42L10 36V27L4 21L10 11L18 14L24 11Z M32 21A11 11 0 1 0 32 43A11 11 0 1 0 32 21','#fff','fill-rule="evenodd"'),
 Coin:`<defs><linearGradient id="gold" x2="0" y2="1"><stop stop-color="#fff44a"/><stop offset="1" stop-color="#ffb900"/></linearGradient></defs>${circle(32,32,29,'#ff9400')}${circle(32,30,27,'url(#gold)')}${circle(32,30,20,'#f4bd00')}${circle(32,29,18,'#ffdc28')}<path d="M10 25A23 23 0 0 1 31 7" fill="none" stroke="#fff879" stroke-width="2"/>`,
 Gem:pathTag('M3 19L16 4H48L61 19L32 61Z','#008bdf')+pathTag('M3 19L16 4L24 19Z','#6ef3ff')+pathTag('M16 4H48L40 19H24Z','#28d9ff')+pathTag('M48 4L61 19H40Z','#9bf8ff')+pathTag('M3 19H24L32 61Z','#0099e9')+pathTag('M24 19H40L32 61Z','#26c9ff')+pathTag('M40 19H61L32 61Z','#0061c8'),
 Store:`<g stroke="#fff" stroke-width="3.4" fill="none"><path d="M27 8V4H37V8"/><circle cx="32" cy="25" r="17"/></g>${circle(26,21,3,'#fff')}${circle(35,18,3,'#fff')}${circle(38,27,3,'#fff')}${circle(29,29,3,'#fff')}${circle(23,30,2.6,'#fff')}${pathTag('M17 40H47L52 58H12Z')}${pathTag('M8 58H56V62H8Z')}${pathTag('M27 46H37V51H27Z','#19334d')}`,
 Inventory:pathTag('M5 15L30 3L59 14L34 27Z')+pathTag('M5 20L29 32V60L5 46Z','#e5eff7')+pathTag('M35 33L59 21V47L35 60Z')+pathTag('M18 9L45 22V32L39 36V25L13 12Z','#15314b')+pathTag('M44 38L54 34V42L44 47Z','#15314b'),
 Emote:circle(31,10,7,'#fff')+pathTag('M25 21H38V43H35V61H29V43H25V27L9 24V18L25 21M38 21L55 17L57 23L38 29'),
 Gift:pathTag('M5 28H59V58H5Z M2 18H62V27H2Z')+pathTag('M29 18H36V60H29Z','#15314b')+`<path d="M30 17C7 17 8-2 24 6L32 17L40 5C55-2 58 17 34 17" fill="none" stroke="#fff" stroke-width="5"/>`,
 Invite:pathTag('M3 12H61V52H3Z')+`<path d="M4 14L32 36L60 14M4 51L24 31M60 51L40 31" fill="none" stroke="#17314c" stroke-width="4"/>`,
 Trade:`<g stroke="#fff" stroke-width="6" stroke-linejoin="round" fill="none"><path d="M10 24L22 12L34 20L44 12L57 26L40 44L24 34L18 41L6 27"/><path d="M23 20L39 31L34 37M9 9L4 18M55 45L61 35"/></g>`,
 Quest:pathTag('M12 6H50V59H12Z','#e9f5ff')+pathTag('M16 11H46V54H16Z','#72b2d8')+`<path d="M22 20H40M22 29H39M22 38H31M28 49L49 22L55 27L34 54Z" fill="none" stroke="#fff" stroke-width="4"/>`,
 Reroll:`<g fill="none" stroke="#fff" stroke-width="5" stroke-linecap="round"><path d="M49 16A22 22 0 0 0 14 46M15 49A22 22 0 0 0 51 19"/></g>`+pathTag('M39 14L56 9L54 28Z')+pathTag('M25 50L8 55L10 36Z'),
 Crown:pathTag('M4 13L19 27L32 5L45 27L60 13L52 48H12Z','#ffc000')+pathTag('M13 53H51V60H13Z','#ffcc17')+pathTag('M32 22L39 32L32 43L25 32Z','#3520bd'),
 Close:`<path d="M14 10L54 54M52 10L12 54" fill="none" stroke="#111" stroke-width="14"/><path d="M14 10L54 54M52 10L12 54" fill="none" stroke="#fff" stroke-width="9"/>`,
 Help:`<path d="M18 18C20 3 47 3 48 20C48 30 30 29 31 42" stroke="#fff" stroke-width="8" fill="none"/>${circle(31,54,4.5,'#fff')}`,
 Chat:`<path d="M13 7H51Q58 7 58 15V44L43 57H13Q6 57 6 49V15Q6 7 13 7ZM42 57V44H58" fill="none" stroke="#fff" stroke-width="3.5"/>${circle(22,24,2.6,'#fff')}${circle(41,24,2.6,'#fff')}<path d="M20 33Q32 44 43 32" fill="none" stroke="#fff" stroke-width="3"/>`,
 Events:pathTag('M6 5H28V28H6Z M36 5H58V28H36Z M6 36H28V59H6Z M36 36H58V59H36Z'),
 Fusion:`<g stroke="#fff" stroke-width="4" fill="none"><path d="M17 19L32 11L47 19V39L32 48L17 39ZM17 19L32 28L47 19M32 28V48"/><path d="M13 8A29 29 0 1 0 52 12"/></g>${pathTag('M45 2L58 13L40 13Z')}`,
 Axe:`<path d="M32 6L33 61" stroke="#54382c" stroke-width="8"/><path d="M31 5L32 60" stroke="#93654b" stroke-width="5"/>${pathTag('M35 11C44 11 51 7 56 1C62 15 62 29 49 42C52 31 46 25 35 26Z','#d7e4ef')}${pathTag('M35 11C44 11 51 7 56 1L58 6C53 14 45 17 35 17Z','#fff')}${pathTag('M23 13H36V23H23Z','#c0cfdf')}`,
 Blade:pathTag('M31 1L39 17L36 45H27L24 17Z','#b9d4ed')+pathTag('M31 1L32 45H36L39 17Z','#eff9ff')+pathTag('M21 44H43V48H21Z','#5f5a50')+pathTag('M28 48H35V62H28Z','#67523f'),
 Ufo:`<ellipse cx="32" cy="41" rx="29" ry="14" fill="#6c859c"/><ellipse cx="32" cy="36" rx="29" ry="14" fill="#c7dfeb"/><ellipse cx="32" cy="31" rx="18" ry="8" fill="#759faf"/>${circle(32,22,13,'#2cd9e9')}${circle(28,17,5,'#99ffff')}${[12,25,39,52].map(x=>circle(x,43,2,'#fff750')).join('')}`,
 Explosion:[[-15,3,12],[-7,-12,13],[9,-16,9],[20,-1,13],[7,13,14],[-15,19,8],[25,24,4],[-27,-19,3],[24,-25,3]].map(([x,y,r])=>circle(32+x,32+y,r,r%2?'#08bfea':'#31dcff')).join(''),
 Parasol:pathTag('M4 26L27 4L49 7L62 20L31 34Z','#118dda')+pathTag('M4 26L27 4L31 34Z','#1fb9ee')+pathTag('M27 4L49 7L31 34Z','#72e7ff')+`<path d="M31 31L42 61" stroke="#c5d6e4" stroke-width="3"/>`,
 Balloons:`<g stroke="#172333" stroke-width="1.3">${[14,28,40,53].map((x,i)=>`<path d="M${x} 25L33 59"/>`).join('')}</g>`+[[14,24,'#ffe000'],[28,14,'#aa55ef'],[40,17,'#1ad6f4'],[53,26,'#b8e600'],[31,30,'#ff608e']].map(([x,y,c])=>`<ellipse cx="${x}" cy="${y}" rx="11" ry="14" fill="${c}"/>${circle(x-3,y-5,3,'#ffffff77')}`).join('')+pathTag('M33 53L24 58L29 63L33 60L38 64L42 58Z','#e42b44'),
 Check:`<path d="M10 32L25 47L56 12" stroke="#fff" stroke-width="8" stroke-linejoin="round" fill="none"/>`,
 Back:pathTag('M30 8L6 32L30 56V41H59V23H30Z'),
 Arrow:pathTag('M6 5L58 32L6 59V43H-5V21H6Z'),
 Sound:`${pathTag('M6 23H17L33 10V54L17 41H6Z')}<path d="M41 21Q52 32 41 43M48 12Q67 32 48 52" fill="none" stroke="#fff" stroke-width="4"/>`,
 Diamond:pathTag('M32 3L61 32L32 61L3 32Z'),
 Ring:`<circle cx="32" cy="32" r="25" fill="none" stroke="#fff" stroke-width="5"/>`,
 Spark:pathTag('M32 1L39 25L63 32L39 39L32 63L25 39L1 32L25 25Z'),
 Shadow:`<defs><radialGradient id="shadow"><stop stop-color="#000" stop-opacity=".65"/><stop offset=".6" stop-color="#000" stop-opacity=".3"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient></defs>${circle(32,32,32,'url(#shadow)')}`,
};
const ballColors={Verity:['#ffff55','#e2ee00','#a5b500'],Axe:['#79849c','#45536c','#1c2c42'],Poison:['#91e830','#64ce0b','#319100'],Burst:['#ffc42a','#f58b13','#c04b03'],Cell:['#c2ed95','#79c976','#2f8a67'],Vampire:['#f34c44','#cf141e','#7f0c1c'],Acid:['#8ada1d','#5bb500','#348300'],Blade:['#697f98','#3e5268','#192d44'],WDC:['#4f92ff','#1648c2','#073385'],Orbit:['#91f1ff','#3598d8','#20538b'],Ray:['#ffd398','#ef8c26','#9b4510'],Laser:['#d166ff','#9d27dd','#471476']};
const balls={};
for(const [id,colors] of Object.entries(ballColors)){
 const grad=id+'G',clip=id+'Clip';
 let s=`<defs><radialGradient id="${grad}" cx="31%" cy="23%" r="77%">${colors.map((c,i)=>`<stop offset="${[0,.55,1][i]}" stop-color="${c}"/>`).join('')}</radialGradient><clipPath id="${clip}"><circle cx="64" cy="64" r="44"/></clipPath><filter id="${id}Blur"><feGaussianBlur stdDeviation="2.4"/></filter></defs>`;
 s+=circle(64,64,44,'url(#'+grad+')','stroke="#172e32" stroke-opacity=".25" stroke-width=".7"');
 let inside='';
 if(id==='Verity')inside=`<ellipse cx="51" cy="52" rx="4.3" ry="7.2" fill="#1d2609"/><ellipse cx="77" cy="52" rx="4.3" ry="7.2" fill="#1d2609"/><path d="M34 69C47 95 83 96 96 68M32 67L36 71M94 69L97 66" fill="none" stroke="#1d2609" stroke-width="2.3" stroke-linecap="round"/>`;
 if(id==='Acid')inside=[[63,48,14],[39,62,8],[54,84,5],[54,96,3],[65,73,3.5],[92,77,8],[85,33,5]].map(([x,y,r])=>circle(x,y,r,'#4a970b','opacity=".78"')).join('');
 if(id==='Axe'||id==='Blade'){
  const d='M61 19Q78 61 62 109';const color=id==='Axe'?'#ff801a':'#26dfff',core=id==='Axe'?'#ffdc72':'#afffff';
  inside=`<path d="${d}" fill="none" stroke="${color}" stroke-width="18" opacity=".55" filter="url(#${id}Blur)"/><path d="${d}" fill="none" stroke="${color}" stroke-width="10"/><path d="${d}" fill="none" stroke="${core}" stroke-width="4.4"/>`;
 }
 if(id==='Burst')inside=pathTag('M57 39H71V57H89V71H71V89H57V71H39V57H57Z','#ffdd78');
 if(id==='Cell')inside=circle(64,64,39,'none','stroke="#c2fbc6" stroke-width="3" stroke-opacity=".65"')+circle(64,64,34,'#b7e89c','opacity=".5"')+circle(62,63,20,'#caff95','filter="url(#CellBlur)"')+circle(62,63,14,'#deffab','opacity=".65"');
 if(id==='WDC')inside=`<g stroke="#d2eaff" stroke-width="2.8" fill="none"><path d="M43 19Q30 64 43 108M82 19Q96 64 82 108M20 48Q64 40 108 48M20 80Q64 88 108 80"/></g>`;
 if(id==='Orbit')inside=`<ellipse cx="64" cy="64" rx="57" ry="15" fill="none" stroke="#c7f9ff" stroke-width="3.5" transform="rotate(-25 64 64)"/>`;
 if(id==='Ray')inside=`<path d="M21 63H107" stroke="#fff1af" stroke-width="6"/><circle cx="64" cy="64" r="17" fill="#ffdf76"/>`;
 if(id==='Laser')inside=circle(64,64,43,'none','stroke="#f3b9ff" stroke-width="3.3"')+circle(51,48,11,'#e9a9ff','filter="url(#LaserBlur)" opacity=".65"');
 s+=`<g clip-path="url(#${clip})">${inside}</g>`;
 if(id==='Vampire')s+=pathTag('M42 102L47 124L54 106Z M75 107L81 124L87 102Z','#f7ffff');
 if(id==='Orbit')s+=`<path d="M11 77Q63 103 117 52" fill="none" stroke="#a8efff" stroke-width="3"/>`;
 balls[id]=s;
}
const metadata={};
for(const [name,items,cell,sourceSize,columns] of [['icons',icons,128,64,8],['balls',balls,256,128,4]]){
 const list=Object.entries(items), rows=Math.ceil(list.length/columns);metadata[name]={cell,width:columns*cell,height:rows*cell,entries:{}};
 const groups=list.map(([id,body],i)=>{const x=(i%columns)*cell,y=Math.floor(i/columns)*cell;metadata[name].entries[id]={x,y,w:cell,h:cell};return `<g transform="translate(${x} ${y}) scale(${cell/sourceSize})"><defs><clipPath id="${name}Cell${i}"><rect width="${sourceSize}" height="${sourceSize}"/></clipPath></defs><g clip-path="url(#${name}Cell${i})">${body}</g></g>`;}).join('');
 const source=svg(groups,columns*cell,rows*cell);
 writeFileSync(path.join(out,name+'.svg'),source);
 writeFileSync(path.join(out,name+'.png'),new Resvg(source).render().asPng());
}
writeFileSync(path.join(out,'atlas.json'),JSON.stringify(metadata,null,2));
console.log(`Authored ${Object.keys(icons).length} icons and ${Object.keys(balls).length} ball portraits.`);
