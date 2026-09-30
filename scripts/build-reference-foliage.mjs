import {readFile,writeFile} from 'node:fs/promises';
import {PNG} from 'pngjs';
const dir='game/assets/2d/production/';
const source=PNG.sync.read(await readFile('source_assets/2d/production/reference_foliage_v2.png'));
const names=['oak','oak_b','orchard','hedge','blossom','willow'];
for(let i=0;i<6;i++){
 const boxes=[[0,0,0.338,.5],[.345,0,.678,.5],[.687,0,1,.5],[0,.63,.35,.95],[.358,.51,.674,1],[.687,.5,1,1]];
 const [x0,y0,x1,y1]=boxes[i].map((v,j)=>Math.round(v*(j%2?source.height:source.width)));
 let l=x1,t=y1,r=x0,b=y0;
 for(let y=y0;y<y1;y++)for(let x=x0;x<x1;x++)if(source.data[(y*source.width+x)*4+3]>30){l=Math.min(l,x);r=Math.max(r,x);t=Math.min(t,y);b=Math.max(b,y);}
 const scale=Math.min(1,384/Math.max(r-l+1,b-t+1));
 const out=new PNG({width:Math.round((r-l+1)*scale),height:Math.round((b-t+1)*scale)});
 for(let y=0;y<out.height;y++)for(let x=0;x<out.width;x++){const a=((t+Math.floor(y/scale))*source.width+l+Math.floor(x/scale))*4;source.data.copy(out.data,(y*out.width+x)*4,a,a+4);}
 await writeFile(dir+'reference_'+names[i]+'.png',PNG.sync.write(out));
}
const meadow=PNG.sync.read(await readFile('source_assets/2d/production/reference_meadow_v2.png'));
const out=new PNG({width:512,height:512});
for(let y=0;y<512;y++)for(let x=0;x<512;x++){let a=(Math.floor(y*meadow.height/512)*meadow.width+Math.floor(x*meadow.width/512))*4;meadow.data.copy(out.data,(y*512+x)*4,a,a+4);}
await writeFile(dir+'reference_meadow.png',PNG.sync.write(out));
