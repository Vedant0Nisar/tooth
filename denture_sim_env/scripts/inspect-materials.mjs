import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const file = resolve(__dirname, '..', 'public', 'dental_model.glb');
const buf = readFileSync(file);

const loader = new GLTFLoader();
loader.parse(
  buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength),
  '',
  (gltf) => {
    const seen = new Set();
    gltf.scene.traverse((node) => {
      if (!node.isMesh) return;
      const m = node.material;
      if (!m) {
        console.log(node.name, '→ NO MATERIAL');
        return;
      }
      const key = m.uuid;
      const tag = seen.has(key) ? '(shared)' : '(new)';
      seen.add(key);
      console.log(
        node.name.padEnd(12),
        '→',
        m.type,
        tag,
        'name:', m.name || '(unnamed)',
        '| color:', m.color ? '#' + m.color.getHexString() : 'n/a',
        '| map:', m.map ? 'yes' : 'no',
        '| vColor:', !!m.vertexColors,
        '| metal:', m.metalness ?? 'n/a',
        '| rough:', m.roughness ?? 'n/a',
      );
      // Also check if geometry has color attribute
      if (node.geometry?.attributes?.color) {
        console.log('   ↳ geometry has vertex color attribute');
      }
    });
  }
);
