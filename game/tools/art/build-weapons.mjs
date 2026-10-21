// Original vector production art derived from the approved flat-ball direction.
// Sources are editable paths, not crops of the concept sheet or reference game.
import { Resvg } from '@resvg/resvg-js';
import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
const out = path.resolve(import.meta.dirname, '../../assets/art/weapon-v3');
mkdirSync(out, { recursive: true });
const ink = '#17151c', steel = '#aab1b5', light = '#f3f3eb', shade = '#525960', gold = '#efbd4c';
const p = (d, fill = steel, extra = '') => `<path d="${d}" fill="${fill}" stroke="${ink}" stroke-width="3" stroke-linejoin="round" ${extra}/>`;
const bevel = d => `<path d="${d}" fill="${light}"/>`;
const line = (d, color = shade, width = 2) => `<path d="${d}" fill="none" stroke="${color}" stroke-width="${width}" stroke-linecap="round"/>`;
const circle = (x,y,r,fill,extra='') => `<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}" ${extra}/>`;
const spear = p('M3 26L28 26L47 6L125 32L47 58L28 38H3Z') + bevel('M47 9L121 32L34 30Z') + line('M34 32H117') + p('M5 24H24V40H5Z',gold);
const dagger = p('M3 22H22L24 5H32L34 18L71 17L125 32L71 47H34L32 59H24L22 42H3Z') + bevel('M36 21L72 20L120 32H36Z') + line('M37 32H119') + p('M24 7H31V57H24Z',shade);
const hammer = p('M5 12L16 4H37L42 12H86L91 4H112L123 12V52L112 60H91L86 52H42L37 60H16L5 52Z',shade) + p('M17 5H36V59H17ZM92 5H111V59H92Z',steel) + bevel('M19 8H33V53L19 57ZM94 8H108V53L94 57Z') + line('M44 17H83',steel,3);
const axe = p('M4 20H31V25H58Q84 25 109 3L118 4Q127 32 118 60Q85 38 58 38H31V44H4Z',shade) + bevel('M113 7L117 7Q124 32 117 56Q88 37 69 35Q93 39 112 47Q117 28 113 7Z') + p('M7 21H22V43H7Z',steel) + line('M35 29H61',steel,3);
const crescent = p('M3 53Q42 61 85 42Q112 27 125 4Q92 28 61 27Q35 27 11 4Q18 31 3 53Z') + bevel('M8 52Q67 57 113 18Q92 48 48 55Z') + line('M15 10Q38 41 74 29');
const mace = p('M6 23L22 19L29 7L47 12L64 3L81 12L99 7L106 19L122 23L117 41L99 57L80 51L64 61L48 51L29 57L11 41Z',shade) + p('M28 22L48 16L65 9L83 17L103 23L98 43L80 48L64 54L45 47L31 43Z') + bevel('M30 24L48 18L64 12L81 20L58 23L40 35Z') + line('M64 13V52M33 27L98 42');
const sickle = p('M3 29H25L36 13Q80 -4 124 17Q104 12 88 29Q63 55 36 61Q52 42 42 32H3Z') + bevel('M39 17Q79 3 112 16Q88 11 70 34Q57 49 42 55Q62 30 39 17Z') + p('M18 23H29V41H18Z',gold);
const star = p('M64 2L80 14L108 8L107 23L125 32L105 42L110 58L82 49L64 62L47 49L18 58L23 41L3 32L24 22L20 7L47 15Z',shade) + `<ellipse cx="64" cy="32" rx="43" ry="22" fill="${shade}" stroke="${ink}" stroke-width="3"/>` + bevel('M30 25Q40 12 65 12L73 20L48 31L31 33Z') + `<ellipse cx="78" cy="39" rx="10" ry="6" fill="${steel}"/>`;
const disc = p('M64 2L85 8L108 6L111 20L125 32L110 43L108 58L84 55L64 62L43 55L20 58L17 43L3 32L18 20L21 6L44 9Z') + `<ellipse cx="64" cy="32" rx="30" ry="19" fill="${ink}"/><ellipse cx="64" cy="32" rx="24" ry="14" fill="none" stroke="${gold}" stroke-width="5"/>` + bevel('M23 17L45 11L63 5L84 11L103 10L96 17L77 17L63 12L48 18Z');
const blade = p('M3 25H20V8H29L34 23L95 18L125 32L95 46L34 41L29 56H20V39H3Z') + bevel('M36 26L93 22L119 32H36Z') + line('M37 32H116') + p('M21 10H28V54H21Z',gold);
const assets = {
 Astra:spear,
 Nerio:p('M3 26H36L70 17L125 3L110 34L70 45H36V38H3Z')+bevel('M40 28L73 21L120 7L105 29L69 34H40Z')+line('M42 34L110 18'),
 Veyra:crescent,
 Oren:p('M3 23H21L33 11L125 32L33 53L21 41H3Z')+bevel('M33 14L120 32H23Z')+line('M24 32H117')+p('M4 22H15V42H4Z',gold),
 Sola:spear+ p('M5 40L40 46L26 61L4 53Z','#be2851'),
 Bram:hammer,
 Korra:axe,
 Dorrin:p('M7 24L31 20L43 8L86 8L99 20L120 24V48H80L74 59H55L49 48H7Z',gold)+bevel('M13 27L35 24L46 12H83L88 19H48L37 30H13Z')+line('M16 42H111',shade,5),
 Tala:p('M3 30Q35 5 70 12L84 5L91 19L125 38L103 39L79 29L65 57H50L56 25Q25 23 3 30Z')+bevel('M14 25Q43 10 68 16L79 11L82 20Q48 19 14 25Z')+p('M56 27H68V52H56Z',gold),
 Mako:p('M4 15L22 3L103 6L123 17L119 52L102 61L22 57L4 47Z','#767c7a')+bevel('M8 17L25 7L101 10L116 18L30 17L16 27Z')+line('M49 8L42 29L57 37L48 56',shade,4)+p('M78 9L89 10L86 57H76Z','#b8a77f'),
 Nix:dagger,
 Iria:p('M3 24H24L33 15L37 23Q84 38 125 4Q115 48 64 49L35 39L31 59H22V41H3Z')+bevel('M39 29Q83 43 119 14Q100 47 64 44L39 35Z')+p('M23 19L30 17L33 54L25 55Z',gold),
 Zefi:p('M3 29L31 20L118 3L125 18L119 32L125 47L118 61L31 44L3 35Z','#a5c9c5')+line('M15 32L116 11M15 32H117M15 32L116 54',gold,4)+bevel('M116 7L121 18L116 30L120 47L116 57L111 44L113 31L110 19Z'),
 Perri:sickle,
 Rook:blade+p('M44 26H90L104 32L90 38H44Z',gold)+line('M49 29H85',light,2),
 Kesh:star,
 Mira:p('M3 27L32 17L58 25L85 15L125 30L100 46L75 38L48 49L22 40Z','#68514c')+line('M8 29L31 23L58 31L85 22L119 31',gold,4)+line('M29 20L24 39M55 27L49 44M84 19L77 36M107 26L101 41',ink,3),
 Toren:p('M3 5L30 13L24 29Q60 56 102 28L97 13L125 5L117 41L102 38Q65 67 25 41L10 43Z')+bevel('M9 10L24 15L18 30Q62 62 108 29L105 15L120 10L114 34L106 32Q64 65 21 35L14 36Z'),
 Vaska:p('M3 32L19 15L49 3L85 8L112 19L125 32L106 49L79 61L44 55L17 48Z','#b9d8df')+p('M22 30L49 9L81 13L105 31L78 54L45 49Z','#82a5b4')+bevel('M26 28L49 13L79 17L59 28L45 44Z')+line('M59 28L78 50M59 28L100 31'),
 Edda:mace,
 Luma:spear,
 Bori:hammer,
 Cira:p('M3 22L20 12H107L124 23V42L107 52H20L3 42Z','#a7c2cc')+bevel('M9 24L23 17H103L116 24H25L12 31Z')+p('M16 14H24V50H16ZM101 15H109V49H101Z',gold)+line('M34 24H89',light,3),
 Fen:blade,
 Runa:sickle,
 Ravi:disc,
 Tavi:p('M4 48L46 4L65 8L124 50L103 60L59 29L24 60Z')+bevel('M10 47L47 9L62 12L117 50L104 54L58 24L23 53Z')+line('M47 12L59 24L107 55'),
 Suri:p('M3 32L20 9L65 3L106 13L125 33L103 54L60 61L20 54Z','#777b80')+bevel('M10 30L24 14L64 8L96 17L59 20L30 40Z')+line('M35 46L62 53L99 45',shade,4),
 Enna:p('M3 24L30 19Q49 2 79 5L122 26L125 38L80 58Q48 62 30 44L3 40Z','#835f43')+p('M41 24Q64 3 109 28Q85 60 45 40Z','#9bba63')+bevel('M46 25Q71 11 102 28L72 29L48 36Z')+line('M45 35L102 28','#49683e',3),
 Pax:p('M3 19H36V12H88V6H124V58H88V52H36V45H3Z',shade)+p('M5 21H34V43H5ZM39 15H86V49H39ZM91 9H121V55H91Z',steel)+bevel('M7 22H31V28H7ZM41 17H83V24H41ZM93 11H118V18H93Z')+line('M97 48H115',gold,4),
 Guard:p('M64 3L121 12L114 39Q100 55 64 61Q28 55 14 39L7 12Z',steel)+p('M64 9L109 16L103 37Q92 48 64 54Q36 48 25 37L19 16Z',shade)+p('M56 12H72V49H56ZM28 25H100V33H28Z',gold)+bevel('M13 14L18 35Q32 52 62 57Q29 47 26 34L23 18L63 8Z'),
 Seed:circle(64,32,29,'#91bc62',`stroke="${ink}" stroke-width="3"`)+p('M64 53Q30 22 47 10Q66 13 64 53Z','#cee797')+p('M64 52Q64 13 90 13Q103 40 64 52Z','#607d45'),
 Wood:p('M2 17H126V47H2Z','#76513b')+bevel('M5 20H123V25H5Z')+line('M14 26L22 44M29 26L37 44M44 26L52 44M59 26L67 44M74 26L82 44M89 26L97 44M104 26L112 44','#3a2925',2),
 Metal:p('M2 17H126V47H2Z',shade)+bevel('M5 20H123V26H5Z')+p('M14 18H22V46H14ZM104 18H112V46H104Z',gold),
 Chain:Array.from({length:5},(_,i)=>`<ellipse cx="${16+i*24}" cy="32" rx="14" ry="${i%2?5:13}" fill="none" stroke="${ink}" stroke-width="8"/><ellipse cx="${16+i*24}" cy="32" rx="14" ry="${i%2?5:13}" fill="none" stroke="${steel}" stroke-width="4"/>`).join(''),
 Collar:p('M47 3H81V61H47Z',gold)+bevel('M51 7H59V57H51Z'),
 Body:circle(64,64,61,ink)+circle(64,64,57,'#9c9c9c')+circle(59,59,53,'#e8e8e8')+bevel('M12 58Q13 14 62 9Q84 9 100 24Q47 2 12 58Z'),
 Glint:bevel('M12 58Q13 14 62 9Q84 9 100 24Q47 2 12 58Z'),
};
const names=Object.keys(assets), metadata={cell:128,columns:8,entries:{}};
const groups=names.map((name,i)=>{const x=i%8*128,y=Math.floor(i/8)*128,h=['Body','Glint'].includes(name)?128:64;metadata.entries[name]={x,y,w:128,h};return `<g transform="translate(${x} ${y})">${assets[name]}</g>`;}).join('');
const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="${Math.ceil(names.length/8)*128}">${groups}</svg>`;
writeFileSync(path.join(out,'weapons.svg'),svg);
writeFileSync(path.join(out,'weapons.png'),new Resvg(svg).render().asPng());
writeFileSync(path.join(out,'atlas.json'),JSON.stringify(metadata,null,2)+'\n');
console.log(`Authored ${names.length} sprites, including 30 weapon heads. ${out}`);
