import {readFile,writeFile} from 'node:fs/promises';
import {PNG} from 'pngjs';
const dir='game/assets/2d/production/';
const source=PNG.sync.read(await readFile('source_assets/2d/production/reference_buildings_v3.png'));
const names=['barn','shed','workshop','feed','silos','packing'];
for(let i=0;i<6;i++){
 const boxes=[[.02,.04,.33,.49],[.34,.08,.71,.47],[.75,.12,.98,.47],[.02,.54,.34,.90],[.38,.55,.63,.9],[.64,.55,.99,.91]];
 const [x0,y0,x1,y1]=boxes[i].map((v,j)=>Math.round(v*(j%2?source.height:source.width)));
 let l=x1,t=y1,r=x0,b=y0;
 for(let y=y0;y<y1;y++)for(let x=x0;x<x1;x++)if(source.data[(y*source.width+x)*4+3]>30){l=Math.min(l,x);r=Math.max(r,x);t=Math.min(t,y);b=Math.max(b,y);}
 const scale=Math.min(1,512/Math.max(r-l+1,b-t+1));
 const out=new PNG({width:Math.round((r-l+1)*scale),height:Math.round((b-t+1)*scale)});
 for(let y=0;y<out.height;y++)for(let x=0;x<out.width;x++){const a=((t+Math.floor(y/scale))*source.width+l+Math.floor(x/scale))*4;source.data.copy(out.data,(y*out.width+x)*4,a,a+4);}
 await writeFile(dir+'reference_'+names[i]+'.png',PNG.sync.write(out));
}
