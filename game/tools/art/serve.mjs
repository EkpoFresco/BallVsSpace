import http from 'node:http';
import {readFileSync} from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'../../assets/art');
http.createServer((req,res)=>{
  const name = req.url?.slice(1);
  if (!['icons.png','balls.png','weapon-v3/weapons.png','ui-v4/icons.png','ui-v4/studs.png'].includes(name)) {res.writeHead(404);res.end();return;}
  res.writeHead(200,{'Content-Type':'image/png'});res.end(readFileSync(path.join(root,name)));
}).listen(24863,'127.0.0.1',()=>console.log('Project art server on 127.0.0.1:24863'));
