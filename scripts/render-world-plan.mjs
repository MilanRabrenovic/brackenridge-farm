import { mkdir, readFile, writeFile } from 'node:fs/promises';

const layout = JSON.parse(await readFile('game/data/world_layout.json', 'utf8'));
const scale = 10;
const halfWidth = layout.bounds.width / 2;
const halfDepth = layout.bounds.depth / 2;
const width = layout.bounds.width * scale;
const height = layout.bounds.depth * scale;
const point = ([x, z]) => `${(x + halfWidth) * scale},${(z + halfDepth) * scale}`;
const districtColours = {
  yard: '#d9ad6f', hay: '#9dbb68', pasture: '#79a45d', crop: '#d9b84f',
  orchard: '#668e50', meadow: '#78aa86', loading: '#c88d58', delivery: '#89938f',
};

const districts = layout.districts.map((district) => `
  <polygon points="${district.points.map(point).join(' ')}" fill="${districtColours[district.kind] ?? '#829b68'}" stroke="#f6e6bd" stroke-width="5"/>
  <text x="${(district.x + halfWidth) * scale}" y="${(district.z + halfDepth) * scale}" class="district">${district.label}</text>`).join('');

const roads = layout.roads.map((road) => `
  <polyline points="${road.points.map(point).join(' ')}" fill="none" stroke="#5c442f" stroke-opacity=".26" stroke-width="${road.width * scale + 8}" stroke-linecap="round" stroke-linejoin="round"/>
  <polyline points="${road.points.map(point).join(' ')}" fill="none" stroke="${road.kind === 'foot' ? '#d9c397' : '#ead09c'}" stroke-width="${road.width * scale}" stroke-linecap="round" stroke-linejoin="round" ${road.kind === 'foot' ? 'stroke-dasharray="15 10"' : ''}/>`).join('');

const structures = layout.structures.map((building) => {
  const x = (building.x + halfWidth) * scale;
  const y = (building.z + halfDepth) * scale;
  if (building.radius) return `<g><circle cx="${x}" cy="${y}" r="${building.radius * scale}" class="building"/><text x="${x}" y="${y + 5}" class="structure">${building.label}</text></g>`;
  const w = building.width * scale;
  const h = building.depth * scale;
  return `<g transform="rotate(${building.rotation ?? 0} ${x} ${y})"><rect x="${x - w / 2}" y="${y - h / 2}" width="${w}" height="${h}" rx="12" class="building"/></g><text x="${x}" y="${y + 5}" class="structure">${building.label}</text>`;
}).join('');

const gates = layout.gates.map((gate) => {
  const x = (gate.x + halfWidth) * scale;
  const y = (gate.z + halfDepth) * scale;
  const half = gate.width * scale / 2;
  return `<g transform="rotate(${gate.rotation ?? 0} ${x} ${y})"><line x1="${x - half}" y1="${y}" x2="${x + half}" y2="${y}" class="gate"/></g>`;
}).join('');

const activities = [
  [-48, -32, 'A', 'SHEEP + GATE'],
  [42, -33, 'B', 'BARLEY + WEATHER'],
  [-17, 2, 'C', 'REPAIR + PARTS'],
  [52, 11, 'D', 'ORCHARD + APIARY'],
  [12, 39, 'E', 'PACK + LOAD'],
  [62, 45, 'F', 'FINAL DISPATCH'],
];
const activitySvg = activities.map(([x, z, key, label]) => {
  const px = (x + halfWidth) * scale;
  const py = (z + halfDepth) * scale;
  return `<g><circle cx="${px}" cy="${py}" r="25" class="activity"/><text x="${px}" y="${py + 7}" class="activity-key">${key}</text><text x="${px + 35}" y="${py + 7}" class="activity-label">${label}</text></g>`;
}).join('');

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title desc">
<title id="title">Brackenridge Farm production map</title>
<desc id="desc">Layered gameplay blueprint showing irregular districts, routes, buildings, gates and hackathon activity anchors.</desc>
<defs>
  <filter id="shadow"><feDropShadow dx="0" dy="3" stdDeviation="3" flood-opacity=".35"/></filter>
  <pattern id="grid" width="100" height="100" patternUnits="userSpaceOnUse"><path d="M100 0H0V100" fill="none" stroke="#fff" stroke-opacity=".08" stroke-width="2"/></pattern>
  <style>
    .district{font:700 20px system-ui,sans-serif;fill:#fff9df;paint-order:stroke;stroke:#34442e;stroke-width:6px;text-anchor:middle;letter-spacing:1px}
    .building{fill:#384c45;stroke:#fff0c7;stroke-width:5;filter:url(#shadow)}
    .structure{font:700 15px system-ui,sans-serif;fill:#fff7db;paint-order:stroke;stroke:#27332d;stroke-width:5px;text-anchor:middle}
    .gate{stroke:#6f3f27;stroke-width:13;stroke-linecap:round;paint-order:stroke;filter:url(#shadow)}
    .activity{fill:#b94b3f;stroke:#fff4c9;stroke-width:5;filter:url(#shadow)}
    .activity-key{font:800 22px system-ui,sans-serif;fill:#fff;text-anchor:middle}
    .activity-label{font:800 18px system-ui,sans-serif;fill:#fff7db;paint-order:stroke;stroke:#27332d;stroke-width:6px}
    .small{font:600 15px system-ui,sans-serif;fill:#fff5d5}
  </style>
</defs>
<rect width="${width}" height="${height}" fill="#426746"/>
${districts}
${roads}
${structures}
${gates}
${activitySvg}
<rect width="${width}" height="${height}" fill="url(#grid)" pointer-events="none"/>
<g transform="translate(26 28)"><rect width="465" height="95" rx="16" fill="#17271f" fill-opacity=".9" stroke="#f1d58a" stroke-width="3"/><text x="22" y="35" class="small" style="font-size:24px;font-weight:800">BRACKENRIDGE FARM · PRODUCTION MAP</text><text x="22" y="64" class="small">170 × 120 m · central loop · adaptive shared/split camera</text><text x="22" y="86" class="small">Diagram only — runtime world is assembled from layers and scenes</text></g>
<g transform="translate(${width - 275} 28)"><rect width="247" height="112" rx="16" fill="#17271f" fill-opacity=".9" stroke="#f1d58a" stroke-width="3"/><text x="22" y="30" class="small">NORTH ↑</text><text x="22" y="55" class="small">Cream: usable routes</text><text x="22" y="78" class="small">Brown: gates</text><text x="22" y="101" class="small">Red: activity anchors</text></g>
</svg>`;

await mkdir('docs/maps', { recursive: true });
await writeFile('docs/maps/brackenridge-production-map.svg', svg);
console.log('Rendered docs/maps/brackenridge-production-map.svg');
