import { readFile, writeFile } from 'node:fs/promises';
import { PNG } from 'pngjs';

async function extractAtlas(sourcePath, columns, rows, names, keepLargest = false, backgroundThreshold = 24, smoothBackground = false, removeBackground = true) {
  const source = PNG.sync.read(await readFile(sourcePath));
  const jobs = [];
  for (let index = 0; index < names.length; index++) {
    const column = index % columns;
    const row = Math.floor(index / columns);
    const cellLeft = Math.round(column * source.width / columns);
    const cellRight = Math.round((column + 1) * source.width / columns);
    const cellTop = Math.round(row * source.height / rows);
    const cellBottom = Math.round((row + 1) * source.height / rows);
    const cell = new PNG({ width: cellRight - cellLeft, height: cellBottom - cellTop, colorType: 6 });
    for (let y = 0; y < cell.height; y++) {
      const sourceStart = ((cellTop + y) * source.width + cellLeft) * 4;
      source.data.copy(cell.data, y * cell.width * 4, sourceStart, sourceStart + cell.width * 4);
    }
    if (removeBackground) clearConnectedBackground(cell, backgroundThreshold, smoothBackground);
    if (keepLargest) keepLargestAlphaComponent(cell);
    let left = cell.width, right = 0, top = cell.height, bottom = 0;
    for (let y = 0; y < cell.height; y++) {
      for (let x = 0; x < cell.width; x++) {
        if (cell.data[(y * cell.width + x) * 4 + 3] > 10) {
          left = Math.min(left, x); right = Math.max(right, x);
          top = Math.min(top, y); bottom = Math.max(bottom, y);
        }
      }
    }
    if (right <= left || bottom <= top) throw new Error(`No visible pixels for ${names[index]}`);
    const padding = 10;
    left = Math.max(0, left - padding); right = Math.min(cell.width - 1, right + padding);
    top = Math.max(0, top - padding); bottom = Math.min(cell.height - 1, bottom + padding);
    const output = new PNG({ width: right - left + 1, height: bottom - top + 1, colorType: 6 });
    for (let y = 0; y < output.height; y++) {
      const sourceStart = ((top + y) * cell.width + left) * 4;
      const targetStart = y * output.width * 4;
      cell.data.copy(output.data, targetStart, sourceStart, sourceStart + output.width * 4);
    }
    jobs.push(writeFile(`game/assets/2d/production/${names[index]}.png`, PNG.sync.write(output)));
  }
  await Promise.all(jobs);
}

function keepLargestAlphaComponent(image) {
  const visited = new Uint8Array(image.width * image.height);
  let largest = [];
  for (let start = 0; start < visited.length; start++) {
    if (visited[start] || image.data[start * 4 + 3] <= 10) continue;
    const component = [];
    const queue = [start];
    visited[start] = 1;
    for (let cursor = 0; cursor < queue.length; cursor++) {
      const index = queue[cursor]; component.push(index);
      const x = index % image.width, y = Math.floor(index / image.width);
      for (const [nx, ny] of [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]) {
        if (nx < 0 || ny < 0 || nx >= image.width || ny >= image.height) continue;
        const ni = ny * image.width + nx;
        if (!visited[ni] && image.data[ni * 4 + 3] > 10) { visited[ni] = 1; queue.push(ni); }
      }
    }
    if (component.length > largest.length) largest = component;
  }
  const retained = new Uint8Array(image.width * image.height);
  for (const index of largest) retained[index] = 1;
  for (let index = 0; index < retained.length; index++) if (!retained[index]) image.data[index * 4 + 3] = 0;
}

async function extractTerrainAtlas(sourcePath, columns, rows, names) {
  const source = PNG.sync.read(await readFile(sourcePath));
  const jobs = [];
  for (let index = 0; index < names.length; index++) {
    const column = index % columns;
    const row = Math.floor(index / columns);
    const left = Math.round(column * source.width / columns);
    const right = Math.round((column + 1) * source.width / columns);
    const top = Math.round(row * source.height / rows);
    const bottom = Math.round((row + 1) * source.height / rows);
    const output = new PNG({ width: right - left, height: bottom - top, colorType: 6 });
    for (let y = 0; y < output.height; y++) {
      const sourceStart = ((top + y) * source.width + left) * 4;
      source.data.copy(output.data, y * output.width * 4, sourceStart, sourceStart + output.width * 4);
    }
    jobs.push(writeFile(`game/assets/2d/production/terrain_${names[index]}.png`, PNG.sync.write(output)));
  }
  await Promise.all(jobs);
}

async function writeContactShadow() {
  const width = 256;
  const height = 128;
  const output = new PNG({ width, height, colorType: 6 });
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const nx = (x - width / 2) / (width * 0.48);
      const ny = (y - height / 2) / (height * 0.34);
      const distance = nx * nx + ny * ny;
      const alpha = Math.max(0, Math.min(1, 1 - distance));
      const offset = (y * width + x) * 4;
      output.data[offset] = 35;
      output.data[offset + 1] = 42;
      output.data[offset + 2] = 28;
      output.data[offset + 3] = Math.round(82 * alpha * alpha);
    }
  }
  await writeFile('game/assets/2d/production/contact_shadow.png', PNG.sync.write(output));
}

function clearConnectedBackground(image, backgroundThreshold = 24, smoothBackground = false) {
  let classification = image.data;
  if (smoothBackground) {
    classification = Buffer.alloc(image.data.length);
    for (let y = 0; y < image.height; y++) {
      for (let x = 0; x < image.width; x++) {
        const target = (y * image.width + x) * 4;
        let count = 0, red = 0, green = 0, blue = 0;
        for (let sy = Math.max(0, y - 2); sy <= Math.min(image.height - 1, y + 2); sy++) {
          for (let sx = Math.max(0, x - 2); sx <= Math.min(image.width - 1, x + 2); sx++) {
            const source = (sy * image.width + sx) * 4;
            red += image.data[source]; green += image.data[source + 1]; blue += image.data[source + 2]; count++;
          }
        }
        classification[target] = Math.round(red / count);
        classification[target + 1] = Math.round(green / count);
        classification[target + 2] = Math.round(blue / count);
        classification[target + 3] = image.data[target + 3];
      }
    }
  }
  const visited = new Uint8Array(image.width * image.height);
  const queue = [];
  const enqueue = (x, y) => {
    const index = y * image.width + x;
    if (!visited[index]) { visited[index] = 1; queue.push(index); }
  };
  for (let x = 0; x < image.width; x++) { enqueue(x, 0); enqueue(x, image.height - 1); }
  for (let y = 1; y < image.height - 1; y++) { enqueue(0, y); enqueue(image.width - 1, y); }
  let cursor = 0;
  while (cursor < queue.length) {
    const index = queue[cursor++];
    const x = index % image.width;
    const y = Math.floor(index / image.width);
    const offset = index * 4;
    const neighbours = [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]];
    for (const [nx, ny] of neighbours) {
      if (nx < 0 || ny < 0 || nx >= image.width || ny >= image.height) continue;
      const ni = ny * image.width + nx;
      if (visited[ni]) continue;
      const no = ni * 4;
      const dr = classification[offset] - classification[no];
      const dg = classification[offset + 1] - classification[no + 1];
      const db = classification[offset + 2] - classification[no + 2];
      const colourDistance = Math.sqrt(dr * dr + dg * dg + db * db);
      // Image-generation backgrounds often contain a soft vignette even when a
      // flat/transparent plate was requested. A generous local threshold lets
      // the flood follow that smooth gradient but still stops at the crisp,
      // high-contrast silhouette of the authored object.
      if (image.data[no + 3] < 48 || colourDistance < backgroundThreshold) {
        visited[ni] = 1;
        queue.push(ni);
      }
    }
  }
  for (const index of queue) image.data[index * 4 + 3] = 0;
}

await extractAtlas('source_assets/2d/production/buildings_atlas.png', 3, 2, [
  'stone_barn', 'machinery_shed', 'repair_workshop',
  'feed_store', 'grain_silos', 'packing_canopy',
]);
await extractAtlas('source_assets/2d/production/environment_atlas.png', 4, 2, [
  'oak_tree', 'willow_tree', 'orchard_tree', 'flowering_tree',
  'hedge_straight', 'hedge_curve', 'drystone_wall', 'farm_gate',
]);
await extractTerrainAtlas('source_assets/2d/production/terrain_atlas.png', 4, 2, [
  'pasture', 'hay', 'orchard', 'meadow',
  'yard', 'track', 'unprepared_soil', 'furrow_soil',
]);
await extractAtlas('source_assets/2d/production/hedge_modules_atlas.png', 4, 2, [
  'hedge_horizontal', 'hedge_vertical', 'hedge_corner_tl', 'hedge_corner_tr',
  'hedge_corner_bl', 'hedge_corner_br', 'hedge_end', 'hedge_gate',
]);
await extractAtlas('source_assets/2d/production/wall_modules_atlas.png', 4, 2, [
  'wall_horizontal', 'wall_vertical', 'wall_corner_tl', 'wall_corner_tr',
  'wall_corner_bl', 'wall_corner_br', 'wall_end', 'wall_gate',
], true);
await extractAtlas('source_assets/2d/production/crop_stages_atlas.png', 4, 2, [
  'crop_seedling_cluster', 'crop_young_cluster', 'crop_mature_cluster', 'crop_damaged_cluster',
  'crop_seeded_row', 'crop_stubble_cluster', 'crop_headland_cluster', 'crop_cut_swath',
], true, 24, false, false);
await extractAtlas('source_assets/2d/production/boundary_modules_v2_atlas.png', 4, 2, [
  'hedge_horizontal_v2', 'hedge_vertical_v2', 'hedge_corner_v2', 'hedge_gate_v2',
  'wall_horizontal_v2', 'wall_vertical_v2', 'wall_corner_v2', 'wall_gate_v2',
], true, 24, false, false);
await extractAtlas('source_assets/2d/production/farm_infrastructure_atlas.png', 4, 2, [
  'stone_bridge', 'shallow_ford', 'hay_bale_stack', 'farm_supplies',
  'tool_station', 'water_trough', 'produce_crates', 'destination_signpost',
], true, 24, false, false);
await extractAtlas('source_assets/2d/production/operational_assets_atlas.png', 4, 2, [
  'sheep_alert', 'sheep_grazing', 'apiary_hives', 'grain_intake',
  'farm_trailer', 'delivery_van', 'produce_pallet', 'spare_parts_crate',
], true, 24, false, false);
await writeContactShadow();
console.log('Prepared buildings, terrain, crop stages, boundaries, infrastructure, operational assets and contact shadow.');
