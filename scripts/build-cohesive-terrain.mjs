import {readFile,writeFile} from 'node:fs/promises';
import {PNG} from 'pngjs';
const root='game/assets/2d/production/';
async function crop(source,box,name,limit=512){
 const [x0,y0,x1,y1]=box.map((v,i)=>Math.round(v*(i%2?source.height:source.width)));
 let l=x0,t=y0,r=x1-1,b=y1-1;
 if(name.startsWith('verge_')){
  l=x1;t=y1;r=x0;b=y0;
  for(let y=y0;y<y1;y++)for(let x=x0;x<x1;x++)if(source.data[(y*source.width+x)*4+3]>40){l=Math.min(l,x);r=Math.max(r,x);t=Math.min(t,y);b=Math.max(b,y);}
 }
 const scale=Math.min(1,limit/Math.max(r-l+1,b-t+1));
 const out=new PNG({width:Math.round((r-l+1)*scale),height:Math.round((b-t+1)*scale)});
 for(let y=0;y<out.height;y++)for(let x=0;x<out.width;x++){
  const src=((t+Math.min(b-t,Math.floor(y/scale)))*source.width+l+Math.min(r-l,Math.floor(x/scale)))*4;
  source.data.copy(out.data,(y*out.width+x)*4,src,src+4);
 }
 await writeFile(root+name+'.png',PNG.sync.write(out));
}
const atlas=PNG.sync.read(await readFile('source_assets/2d/production/cohesive_terrain_atlas.png'));
for(const [i,name] of ['grass','earth','yard','water'].entries())await crop(atlas,[(i%2)/2,Math.floor(i/2)/2,(i%2+1)/2,(Math.floor(i/2)+1)/2],'cohesive_'+name);
await crop(PNG.sync.read(await readFile('source_assets/2d/production/cohesive_grass_source.png')),[0,0,1,1],'cohesive_grass');
const plants=PNG.sync.read(await readFile('source_assets/2d/production/cohesive_verges_atlas.png'));
const regions=[['hedge_h',[0,.17,.35,.45]],['hedge_v',[.36,0,.48,.54]],['reeds',[.51,.11,.70,.48]],['flowers',[.72,.17,1,.49]],['shrub',[.04,.57,.25,.95]],['rocks',[.27,.62,.45,.97]],['wall_h',[.47,.65,.81,.92]],['wall_v',[.84,.54,.95,.99]]];
for(const [name,box]of regions)await crop(plants,box,'verge_'+name);
const layout=JSON.parse(await readFile('game/data/world_layout.json'));
const dist=(x,y,a,b)=>{const dx=b[0]-a[0],dy=b[1]-a[1],t=Math.max(0,Math.min(1,((x-a[0])*dx+(y-a[1])*dy)/(dx*dx+dy*dy)));return Math.hypot(x-a[0]-t*dx,y-a[1]-t*dy);};
const inside=(x,y,p)=>{let c=false;for(let i=0,j=p.length-1;i<p.length;j=i++)if(((p[i][1]>y)!=(p[j][1]>y))&&(x<(p[j][0]-p[i][0])*(y-p[i][1])/(p[j][1]-p[i][1])+p[i][0]))c=!c;return c;};
const smooth=(a,b,x)=>{let t=Math.max(0,Math.min(1,(x-a)/(b-a)));return t*t*(3-2*t);};
const yards=layout.districts.filter(d=>['yard','loading','delivery'].includes(d.kind));
// Round only visual corners within the original, verified route corridor.
function rounded(points){
 const result=[points[0]];
 for(let i=1;i<points.length-1;i++){
  const a=points[i-1],b=points[i],c=points[i+1];
  const ab=Math.hypot(b[0]-a[0],b[1]-a[1]),bc=Math.hypot(c[0]-b[0],c[1]-b[1]);
  const cut=Math.min(2.2,ab*.22,bc*.22);
  const u=[b[0]+(a[0]-b[0])*cut/ab,b[1]+(a[1]-b[1])*cut/ab];
  const v=[b[0]+(c[0]-b[0])*cut/bc,b[1]+(c[1]-b[1])*cut/bc];
  result.push(u);
  for(let k=1;k<=6;k++){const t=k/6;result.push([u[0]*(1-t)**2+2*b[0]*(1-t)*t+v[0]*t*t,u[1]*(1-t)**2+2*b[1]*(1-t)*t+v[1]*t*t]);}
 }
 result.push(points.at(-1));return result;
}
const roads=layout.roads.filter(r=>r.id!=='field_headland').map(r=>({...r,points:rounded(r.points)}));
const yardTracks=[
 {points:[[-8,-7],[-8,-1],[0,4],[8,13],[16,27]],width:4},
 {points:[[12,-10],[12,-3],[6,4]],width:4},
 {points:[[-19,4],[-12,6],[0,4]],width:3},
 {points:[[-19,19],[-9,19],[8,13],[20,15]],width:3}
];
const river=[[-90,46],[-62,43],[-42,47],[-20,55],[12,64]];
const mask=new PNG({width:850,height:600});
const wearMask=new PNG({width:850,height:600});
for(let py=0;py<600;py++)for(let px=0;px<850;px++){
 const x=px/5-85,y=py/5-60;
 const n=.35*Math.sin(x*2.8+y*.7)+.22*Math.sin(y*6.3-x*1.2)+.35*Math.sin(x*.9-y*1.1);
 let yard=0,lane=0,wear=0;
 for(const d of yards){let edge=1e5;for(let i=0;i<d.points.length;i++)edge=Math.min(edge,dist(x,y,d.points[i],d.points[(i+1)%d.points.length]));yard=Math.max(yard,smooth(-1.4,1.5,(inside(x,y,d.points)?edge:-edge)+n));}
 for(const r of roads){let distance=1e5;for(let i=1;i<r.points.length;i++)distance=Math.min(distance,dist(x,y,r.points[i-1],r.points[i]));const half=r.width*(r.kind==='foot'?.36:.34);lane=Math.max(lane,1-smooth(half-.35,half+1.1,distance+n*.65));}
 for(const r of [...roads.filter(r=>r.kind!=='foot'),...yardTracks]){
  let d=1e5;for(let i=1;i<r.points.length;i++)d=Math.min(d,dist(x,y,r.points[i-1],r.points[i]));
  wear=Math.max(wear,(1-smooth(.12,.38,Math.abs(d-r.width*.18)))*(.72+.28*Math.sin(x*1.8+y*2.3)));
 }
 let riverD=1e5;for(let i=1;i<river.length;i++)riverD=Math.min(riverD,dist(x,y,river[i-1],river[i]));
 const water=1-smooth(3.25,4.5,riverD+n*.30);
 const i=(py*850+px)*4;mask.data[i]=Math.round(Math.max(yard,lane)*255);mask.data[i+1]=Math.round(yard*255);mask.data[i+2]=Math.round(water*255);mask.data[i+3]=255;wearMask.data[i]=wearMask.data[i+1]=wearMask.data[i+2]=Math.round(wear*255);wearMask.data[i+3]=255;
}
await writeFile(root+'cohesive_ground_mask.png',PNG.sync.write(mask));
await writeFile(root+'cohesive_wear_mask.png',PNG.sync.write(wearMask));
console.log('Built four terrain tiles, eight verge sprites and measured ground mask.');
