import assert from 'node:assert/strict';
import test from 'node:test';
import { readFile } from 'node:fs/promises';

type District = { id:string; kind:string; x:number; z:number; width:number; depth:number; exits:number; points:[number,number][] };
type Road = { id:string; width:number; points:[number,number][] };
type Destination = { id:string; label:string; position:[number,number]; radius:number; purpose:string };
type Layout = {
  bounds:{width:number;depth:number};
  standards:Record<string,number>;
  vehicles:Record<string,{width:number;length:number}>;
  districts:District[];
  structures:{id:string}[];
  roads:Road[];
  gates:{id:string;width:number;route:string}[];
  destinations:Destination[];
  logistics:Record<string,string[]>;
};

const layout = JSON.parse(await readFile(new URL('../game/data/world_layout.json', import.meta.url), 'utf8')) as Layout;

test('heavy machinery route and gate clear the combine envelope', () => {
  const combine=layout.vehicles.combine;
  const lane=layout.roads.find(road=>road.id==='field_lane');
  const gate=layout.gates.find(item=>item.id==='crop_gate');
  assert.ok(lane && gate);
  assert.ok(lane.width >= combine.width + 2, 'combine lane needs a one-metre shoulder on each side');
  assert.ok(gate.width >= combine.width + 2, 'combine gate needs a one-metre clearance on each side');
  assert.ok(layout.standards.cropHeadlandDepth >= combine.length + 2);
});

test('all operational districts fit inside the playable boundary and have recovery exits', () => {
  for (const district of layout.districts) {
    assert.ok(Math.abs(district.x) + district.width / 2 <= layout.bounds.width / 2, `${district.id} exceeds east/west bounds`);
    assert.ok(Math.abs(district.z) + district.depth / 2 <= layout.bounds.depth / 2, `${district.id} exceeds north/south bounds`);
    assert.ok(district.exits >= 2, `${district.id} needs at least two exits`);
  }
});

test('working fields use irregular countryside boundaries', () => {
  const fields=layout.districts.filter(district=>['hay','pasture','crop','orchard','meadow'].includes(district.kind));
  for (const field of fields) {
    assert.ok(field.points.length >= 5, `${field.id} needs a hand-shaped boundary`);
    assert.ok(new Set(field.points.map(point=>point[0])).size >= 3, `${field.id} is too rectangular on the east/west axis`);
    assert.ok(new Set(field.points.map(point=>point[1])).size >= 3, `${field.id} is too rectangular on the north/south axis`);
  }
});

test('the fieldscape is a connected patchwork with shared boundaries', () => {
  const districts=layout.districts;
  const neighbours=new Map(districts.map(field=>[field.id,new Set<string>()]));
  for (let left=0; left<districts.length; left++) for (let right=left+1; right<districts.length; right++) {
    const leftVertices=new Set(districts[left].points.map(point=>point.join(',')));
    const shared=districts[right].points.filter(point=>leftVertices.has(point.join(','))).length;
    if (shared > 0) {
      neighbours.get(districts[left].id)!.add(districts[right].id);
      neighbours.get(districts[right].id)!.add(districts[left].id);
    }
  }
  const reached=new Set<string>();
  const queue=['yard'];
  while (queue.length) {
    const id=queue.shift()!;
    if (reached.has(id)) continue;
    reached.add(id);
    queue.push(...neighbours.get(id)!);
  }
  const fields=districts.filter(district=>['hay','pasture','crop','orchard','meadow'].includes(district.kind));
  for (const field of fields) assert.ok(reached.has(field.id),`${field.id} should connect to the shared farm patchwork`);
});

test('logistics chains reference defined places, vehicles, gates or storage', () => {
  const identifiers=new Set([
    ...layout.districts.map(item=>item.id),
    ...layout.structures.map(item=>item.id),
    ...layout.gates.map(item=>item.id),
    ...layout.roads.map(item=>item.id),
    ...Object.keys(layout.vehicles),
  ]);
  identifiers.add('trailer');
  for (const [flow, steps] of Object.entries(layout.logistics)) {
    assert.ok(steps.length >= 3, `${flow} is not a meaningful chain`);
    for (const step of steps) assert.ok(identifiers.has(step), `${flow} references missing ${step}`);
  }
});

test('every committed activity has an in-bounds interaction destination', () => {
  const required=['animal_care','repair_bay','grain_intake','crop_gate','pasture_gate','apiary','packing','dispatch','bridge','ford'];
  assert.deepEqual(layout.destinations.map(item=>item.id).sort(),required.sort());
  for (const destination of layout.destinations) {
    assert.ok(Math.abs(destination.position[0]) <= layout.bounds.width / 2,`${destination.id} is outside east/west bounds`);
    assert.ok(Math.abs(destination.position[1]) <= layout.bounds.depth / 2,`${destination.id} is outside north/south bounds`);
    assert.ok(destination.radius >= 6,`${destination.id} interaction radius is too small for TV play`);
    assert.ok(destination.label.length > 2 && destination.purpose.length > 8,`${destination.id} needs readable context`);
  }
});
