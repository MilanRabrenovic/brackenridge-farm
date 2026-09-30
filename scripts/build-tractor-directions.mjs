import {readFile,writeFile} from 'node:fs/promises';
import {PNG} from 'pngjs';
const src=PNG.sync.read(await readFile('source_assets/2d/production/tractor-directions.png'));
for (const [i,name] of ['down','up','left','right'].entries()) {
 const x0=(i%2)*src.width/2,y0=Math.floor(i/2)*src.height/2;
 let l=x0+src.width/2,t=y0+src.height/2,r=x0,b=y0;
 for(let y=Math.ceil(y0+20);y<y0+src.height/2-10;y++)for(let x=Math.ceil(x0+35);x<x0+src.width/2-25;x++)if(src.data[(y*src.width+x)*4+3]>128){l=Math.min(l,x);r=Math.max(r,x);t=Math.min(t,y);b=Math.max(b,y);}
 const scale=Math.min(232/(r-l+1),190/(b-t+1)),w=Math.round((r-l+1)*scale),h=Math.round((b-t+1)*scale);
 const out=new PNG({width:256,height:220});
 for(let y=0;y<h;y++)for(let x=0;x<w;x++){
  const a=((t+Math.floor(y/scale))*src.width+l+Math.floor(x/scale))*4;
  src.data.copy(out.data,((y+210-h)*256+x+Math.floor((256-w)/2))*4,a,a+4);
 }
 await writeFile('game/assets/2d/production/tractor_'+name+'.png',PNG.sync.write(out));
}
// Extract circular tread/hub layers from the coordinated side view for rotation.
const side=PNG.sync.read(await readFile('game/assets/2d/production/tractor_left.png'));
for(const [name,cx,cy,radius] of [['rear',178,161,40],['front',57,178,24]]){
 const out=new PNG({width:radius*2,height:radius*2});
 for(let y=0;y<out.height;y++)for(let x=0;x<out.width;x++)if(Math.hypot(x-radius+.5,y-radius+.5)<radius){
  const index=((cy-radius+y)*side.width+cx-radius+x)*4;
  side.data.copy(out.data,(y*out.width+x)*4,index,index+4);
 }
 await writeFile('game/assets/2d/production/tractor_wheel_'+name+'.png',PNG.sync.write(out));
}
