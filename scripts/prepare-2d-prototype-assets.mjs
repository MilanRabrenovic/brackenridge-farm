import { readFile, writeFile } from 'node:fs/promises';
import { PNG } from 'pngjs';

const source = PNG.sync.read(await readFile('source_assets/2d/prototype/farmhands_source.png'));

function extractCharacter(name, minX, maxX) {
  let left = maxX, right = minX, top = source.height, bottom = 0;
  for (let y = 0; y < source.height; y++) {
    for (let x = minX; x < maxX; x++) {
      const alpha = source.data[(y * source.width + x) * 4 + 3];
      if (alpha > 8) {
        left = Math.min(left, x); right = Math.max(right, x);
        top = Math.min(top, y); bottom = Math.max(bottom, y);
      }
    }
  }
  if (right <= left || bottom <= top) throw new Error(`No visible pixels found for ${name}`);
  const padding = 16;
  left = Math.max(minX, left - padding); right = Math.min(maxX - 1, right + padding);
  top = Math.max(0, top - padding); bottom = Math.min(source.height - 1, bottom + padding);
  const cropWidth = right - left + 1;
  const cropHeight = bottom - top + 1;
  const targetHeight = 192;
  const targetWidth = Math.max(1, Math.round(cropWidth * targetHeight / cropHeight));
  const canvas = new PNG({ width: 160, height: 208, colorType: 6 });
  const offsetX = Math.floor((canvas.width - targetWidth) / 2);
  const offsetY = canvas.height - targetHeight;
  for (let y = 0; y < targetHeight; y++) {
    const sy = top + Math.min(cropHeight - 1, Math.floor(y * cropHeight / targetHeight));
    for (let x = 0; x < targetWidth; x++) {
      const sx = left + Math.min(cropWidth - 1, Math.floor(x * cropWidth / targetWidth));
      const sourceOffset = (sy * source.width + sx) * 4;
      const targetOffset = ((offsetY + y) * canvas.width + offsetX + x) * 4;
      source.data.copy(canvas.data, targetOffset, sourceOffset, sourceOffset + 4);
    }
  }
  return writeFile(`game/assets/2d/prototype/${name}.png`, PNG.sync.write(canvas));
}

await Promise.all([
  extractCharacter('grower', 0, Math.floor(source.width / 2)),
  extractCharacter('mechanic', Math.floor(source.width / 2), source.width),
  prepareWalkSheet('grower'),
  prepareWalkSheet('mechanic'),
]);
console.log('Prepared isolated portraits and four-direction 2D walk sheets.');

async function prepareWalkSheet(name) {
  const input = PNG.sync.read(await readFile(`source_assets/2d/prototype/${name}_walk_sheet.png`));
  const cellSize = 256;
  const output = new PNG({ width: cellSize * 4, height: cellSize * 4, colorType: 6 });

  for (let row = 0; row < 4; row++) {
    const sourceTop = Math.round(row * input.height / 4);
    const sourceBottom = Math.round((row + 1) * input.height / 4);
    for (let column = 0; column < 4; column++) {
      const sourceLeft = Math.round(column * input.width / 4);
      const sourceRight = Math.round((column + 1) * input.width / 4);
      const sourceWidth = sourceRight - sourceLeft;
      const sourceHeight = sourceBottom - sourceTop;

      for (let y = 0; y < cellSize; y++) {
        const sourceY = sourceTop + Math.min(sourceHeight - 1, Math.floor(y * sourceHeight / cellSize));
        for (let x = 0; x < cellSize; x++) {
          const sourceX = sourceLeft + Math.min(sourceWidth - 1, Math.floor(x * sourceWidth / cellSize));
          const sourceOffset = (sourceY * input.width + sourceX) * 4;
          const targetX = column * cellSize + x;
          const targetY = row * cellSize + y;
          const targetOffset = (targetY * output.width + targetX) * 4;
          input.data.copy(output.data, targetOffset, sourceOffset, sourceOffset + 4);
        }
      }
    }
  }

  return writeFile(`game/assets/2d/prototype/${name}_walk.png`, PNG.sync.write(output));
}
