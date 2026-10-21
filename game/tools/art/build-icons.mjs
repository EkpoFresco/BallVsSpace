// Original flat armory UI icons. All geometry is authored here; no external art.
import {Resvg} from '@resvg/resvg-js';
import {mkdirSync,writeFileSync} from 'node:fs';
import path from 'node:path';
const out=path.resolve(import.meta.dirname,'../../assets/art/ui-v4');
mkdirSync(out,{recursive:true});
const ink='#201c24',cream='#f6eee0',steel='#aab8be',gold='#efbd4c',mint='#8eefe5',pink='#ef6c82',wood='#866047';
const p=(d,fill=cream)=>`<path d="${d}" fill="${fill}" stroke="${ink}" stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>`;
const line=(d,color=ink,w=5)=>`<path d="${d}" fill="none" stroke="${color}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
const circle=(x,y,r,color=cream)=>`<circle cx="${x}" cy="${y}" r="${r}" fill="${color}" stroke="${ink}" stroke-width="5"/>`;
const shine=d=>`<path d="${d}" fill="${cream}" opacity=".75"/>`;
const ball=(x,y,r,color)=>circle(x,y,r,color)+shine(`M${x-r+7} ${y}Q${x-r+7} ${y-r+5} ${x+4} ${y-r+6}Q${x-r+12} ${y-r+10} ${x-r+7} ${y}Z`);
const star=p('M64 13L77 44L111 47L85 69L92 104L64 86L36 104L43 69L17 47L51 44Z',gold);
const sword=p('M27 101L48 80L40 72L49 63L58 71L92 23L112 16L105 37L67 80L76 89L67 98L58 90L37 111Z',steel)+line('M60 73L104 25',cream,4)+p('M39 75L49 65L75 90L66 99Z',gold);
const arrow=d=>line(d,ink,18)+line(d,mint,10);
const icons={
 Heart:p('M64 108L20 66Q3 43 18 25Q40 8 64 33Q88 8 110 25Q125 43 108 66Z',pink)+shine('M22 40Q23 23 40 27L47 31Q28 28 22 49Z'),
 Gear:p('M53 12H75L79 28L91 35L107 31L118 50L106 62V76L118 87L106 106L90 101L78 108L74 119H52L49 106L36 99L21 104L10 85L22 74V60L11 48L22 29L38 34L50 27Z',steel)+circle(64,65,21,cream)+circle(64,65,10,wood),
 Coin:circle(64,64,48,gold)+circle(64,64,36,gold)+p('M58 35H70V58H91V70H70V93H58V70H37V58H58Z',cream)+shine('M25 48Q30 24 57 24Q33 30 25 48Z'),
 Gem:p('M32 20H96L117 52L64 112L11 52Z',mint)+p('M32 20L46 52H82L96 20Z',cream)+line('M11 52H117M46 52L64 112L82 52'),
 Store:p('M18 45H110V111H18Z',wood)+p('M12 22H116L109 49Q101 64 88 51Q75 65 64 51Q51 65 39 51Q26 64 18 51Z',pink)+p('M49 74H80V111H49Z',cream)+line('M33 24L39 51M64 24V51M95 24L88 51',cream,6),
 Inventory:p('M15 45L64 20L113 45V102L64 120L15 102Z',wood)+p('M15 45L64 66L113 45L64 20Z',cream)+line('M64 66V117')+ball(64,30,21,mint)+p('M78 62L95 55V76L78 83Z',gold),
 Emote:circle(64,24,13,gold)+line('M64 43V79M64 52L30 37M64 52L95 32M64 79L38 110M64 79L90 107',ink,18)+line('M64 43V79M64 52L30 37M64 52L95 32M64 79L38 110M64 79L90 107',cream,10),
 Gift:p('M20 55H108V113H20Z',mint)+p('M13 38H115V61H13Z',mint)+p('M54 38H74V113H54Z',gold)+p('M64 38Q23 42 26 19Q32 1 50 19ZM64 38Q105 42 102 19Q96 1 78 19Z',pink),
 Invite:p('M12 31H116V105H12Z',cream)+p('M12 31L64 72L116 31Z',mint)+line('M15 102L46 69M113 102L82 69'),
 Trade:arrow('M15 42H107L88 23M107 42L88 61')+arrow('M113 86H21L40 67M21 86L40 105'),
 Quest:p('M22 17H106V115H22Z',cream)+p('M43 10H85V30H43Z',gold)+line('M37 51L44 58L56 45M69 53H91M37 81L44 88L56 75M69 83H91',wood,6),
 Reroll:arrow('M106 50Q94 9 54 19Q23 23 16 55M106 50L109 21M106 50L78 44')+arrow('M22 78Q34 119 74 109Q105 105 112 73M22 78L19 107M22 78L50 84'),
 Crown:p('M18 31L44 54L64 20L84 54L110 31L99 105H29Z',gold)+p('M29 87H99V105H29Z',wood)+circle(64,73,9,pink)+shine('M25 46L34 80H44Z'),
 Close:line('M30 30L98 98M98 30L30 98',ink,24)+line('M30 30L98 98M98 30L30 98',cream,13),
 Help:circle(64,64,48,mint)+line('M46 45Q46 28 65 29Q87 30 83 49Q82 58 65 66V76',ink,10)+circle(65,94,3,ink),
 Chat:p('M14 20H114V91H67L36 115V91H14Z',cream)+circle(38,55,4,wood)+circle(64,55,4,wood)+circle(90,55,4,wood),
 Events:p('M15 24H113V113H15Z',cream)+p('M15 24H113V50H15Z',pink)+line('M36 13V35M92 13V35',steel,10)+`<g transform="translate(27 48) scale(.58)">${star}</g>`,
 Fusion:ball(43,48,30,mint)+ball(87,80,30,pink)+p('M65 32L49 66H66L59 98L83 58H66Z',gold),
 Axe:p('M27 111L88 18L97 24L38 118Z',wood)+p('M63 18Q88 51 116 40L107 73Q72 74 48 39Z',steel)+shine('M58 35Q81 62 109 57L105 67Q78 66 58 35Z'),
 Blade:sword,
 Ufo:p('M31 63Q31 17 64 17Q97 17 97 63Z',mint)+p('M10 68Q21 47 64 49Q107 47 118 68Q106 98 64 98Q22 98 10 68Z',steel)+circle(33,75,6,gold)+circle(64,83,6,pink)+circle(95,75,6,gold)+shine('M41 46Q43 24 62 24Q47 30 41 46Z'),
 Explosion:p('M52 10L69 35L99 16L93 45L119 61L94 76L103 110L72 94L52 119L42 91L11 103L25 74L8 50L40 44Z',pink)+p('M57 34L70 54L91 48L80 69L88 88L65 82L48 98L46 75L28 62L50 57Z',gold),
 Parasol:p('M12 66Q25 12 64 12Q103 12 116 66Q100 53 91 67Q76 54 64 68Q50 53 37 67Q25 53 12 66Z',pink)+line('M64 16Q43 29 37 63M64 16Q85 29 91 63',cream,4)+line('M64 68V101Q64 119 84 108',wood,8),
 Balloons:line('M28 60L64 116L93 67M64 51V116',cream,3)+ball(30,43,23,pink)+ball(91,45,24,mint)+ball(61,29,25,gold),
 Check:line('M25 66L51 92L106 32',ink,24)+line('M25 66L51 92L106 32',mint,14),
 Back:arrow('M108 64H22L52 32M22 64L52 96'),
 Arrow:arrow('M20 64H106L76 34M106 64L76 94'),
 Sound:p('M14 49H37L67 23V105L37 79H14Z',gold)+line('M83 43Q105 64 83 85M97 26Q133 64 97 102',cream,7),
 Diamond:p('M64 13L115 64L64 115L13 64Z',mint)+p('M64 30L96 64L64 98L32 64Z',cream),
 Ring:circle(64,64,45,gold)+circle(64,64,31,ink)+line('M33 40Q45 25 64 26',cream,5),
 Spark:star,
 Shadow:`<ellipse cx="64" cy="84" rx="47" ry="21" fill="${ink}" opacity=".6"/>`+ball(64,52,34,steel),
};
const entries={};
const groups=Object.entries(icons).map(([id,svg],i)=>{const x=i%8*128,y=Math.floor(i/8)*128;entries[id]={x,y,w:128,h:128};return `<g transform="translate(${x} ${y})">${svg}</g>`;}).join('');
const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="512">${groups}</svg>`;
writeFileSync(path.join(out,'icons.svg'),svg);writeFileSync(path.join(out,'icons.png'),new Resvg(svg).render().asPng());
writeFileSync(path.join(out,'atlas.json'),JSON.stringify({cell:128,columns:8,entries},null,2)+'\n');
const studs=`<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024"><defs><pattern id="studs" width="32" height="32" patternUnits="userSpaceOnUse"><circle cx="16" cy="16" r="7" fill="#fff" fill-opacity=".09" stroke="#000" stroke-opacity=".2" stroke-width="1.5"/><path d="M11 15Q12 10 17 10" fill="none" stroke="#fff" stroke-opacity=".16" stroke-width="1.5" stroke-linecap="round"/></pattern></defs><rect width="1024" height="1024" fill="url(#studs)"/></svg>`;
writeFileSync(path.join(out,'studs.svg'),studs);writeFileSync(path.join(out,'studs.png'),new Resvg(studs).render().asPng());
console.log(`Authored ${Object.keys(icons).length} flat armory icons and one 32×32 stud overlay.`);
