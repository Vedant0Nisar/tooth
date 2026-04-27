import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const file = resolve(__dirname, '..', 'public', 'dental_model.glb');
const buf = readFileSync(file);

const loader = new GLTFLoader();
loader.parse(
  buf.buffer.slice(buf.byteOffset, buf.byteOffset + buf.byteLength),
  '',
  (gltf) => {
    gltf.scene.updateMatrixWorld(true);
    console.log('Scene root pos:', gltf.scene.position.toArray(), 'rot:', gltf.scene.rotation.toArray(), 'scale:', gltf.scene.scale.toArray());
    gltf.scene.traverse((node) => {
      if (!node.isMesh) return;
      if (!/^tooth\d*$/i.test(node.name) && !/jaw/i.test(node.name)) return;
      node.geometry.computeBoundingBox();
      const geomBox = node.geometry.boundingBox;
      const geomCenter = geomBox.getCenter(new THREE.Vector3());
      console.log(
        node.name.padEnd(12),
        'localPos:[', node.position.toArray().map(v=>v.toFixed(1)).join(','), ']',
        'geomCenter:[', geomCenter.toArray().map(v=>v.toFixed(1)).join(','), ']',
        'parent:', node.parent?.name || '(none)'
      );
    });
  }
);
