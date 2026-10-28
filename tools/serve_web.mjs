import {createServer} from 'node:http';
import {readFile,stat} from 'node:fs/promises';
import {resolve,extname,sep} from 'node:path';
const root=resolve('build/web');
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.png':'image/png','.ttf':'font/ttf','.otf':'font/otf','.svg':'image/svg+xml'};
const server=createServer(async(req,res)=>{
  try {
    let name=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    let file=resolve(root,'.'+name);
    if(!file.startsWith(root+sep)&&file!==root){res.writeHead(403);res.end();return;}
    if((await stat(file)).isDirectory())file=resolve(file,'index.html');
    const data=await readFile(file);
    res.writeHead(200,{'Content-Type':types[extname(file)]??'application/octet-stream','Cache-Control':'no-cache'});
    res.end(data);
  } catch {res.writeHead(404);res.end('Not found');}
});
server.listen(4173,'127.0.0.1',()=>console.log('NewCare preview: http://127.0.0.1:4173'));

