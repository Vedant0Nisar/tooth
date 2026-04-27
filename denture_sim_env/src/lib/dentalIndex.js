import * as THREE from 'three';

// What we actually find in dental_model.glb:
//   - Upper_jaw, Lowwer_jaw      → gum meshes (note GLB typo: "Lowwer")
//   - Up, Down                   → auxiliary anatomy (bone/skull); not shown
//   - Tooth, Tooth001..Tooth027  → 28 individual teeth (no socket empties)
//
// Since the GLB has no empty socket nodes, we derive sockets from each
// tooth's canonical world transform: that position becomes a labeled slot
// the user can choose from the placement modal.
//
// The GLB's materials are all shared white MeshStandardMaterial with
// metalness=1 / roughness=1 — physically wrong for organic tissue and the
// reason the model renders as a flat dark blob. We replace gum/tooth
// materials with anatomically reasonable PBR via `applyDentalMaterials`.

const NAME_TOOTH = /^tooth\d*$/i;
const NAME_GUM = /jaw|gum|gingiv/i;

// Custom display names keyed by sorted index (1-based, left-to-right per arch).
// Leave an index out to keep the default "Tooth NN" label.
const UPPER_LABELS = {
  1:  'Second Molar',
  2:  'First Molar',
  3:  'Second Bicuspid',
  4:  'First Bicuspid',
  5:  'Canine',
  6:  'Lateral Incisor',
  7:  'Central Incisor',
  8:  'Central Incisor',
  9:  'Lateral Incisor',
  10: 'Canine (Cuspid)',
  11: 'First Bicuspid',
  12: 'Second Bicuspid',
  13: 'First Molar',
  14: 'Second Molar',
};
const LOWER_LABELS = {};

// Saturated gingiva pink + warm enamel ivory. The GLB ships materials at
// roughness=1 / metalness=1, which made everything render dark; we need
// enough chroma here to survive any residual environmental reflection.
const GUM_COLOR = '#c25555';
const TOOTH_COLOR = '#f7ecd6';

/**
 * Walk the GLTF and produce:
 *   gums:    { upper: {name, node} | null, lower: ... }   (rendered in Scene)
 *   teeth:   { upper: [{name, node}], lower: [...] }      (cards + placement)
 *   sockets: { upper: { socketName -> {position, rotation} },
 *              lower: { ... } }                           (snap targets)
 *
 * Arch classification: each mesh is split by Y position around the midpoint
 * between the two tooth-Y clusters. This works for any GLB where upper teeth
 * sit above lower teeth — the typical case.
 */
export function buildSceneIndex(scene, nodes) {
  scene.updateMatrixWorld(true);

  const meshes = [];
  Object.entries(nodes).forEach(([name, node]) => {
    if (!node || !name || !node.isMesh) return;
    const box = new THREE.Box3().setFromObject(node);
    const center = box.getCenter(new THREE.Vector3());
    meshes.push({ name, node, center });
  });

  const teethRaw = meshes.filter((m) => NAME_TOOTH.test(m.name));
  const gumRaw = meshes.filter((m) => NAME_GUM.test(m.name) && !NAME_TOOTH.test(m.name));

  // Compute the Y midpoint between the two tooth clusters. If we don't have
  // teeth, fall back to gum Y midpoint, then 0.
  const midY = computeArchMidY(teethRaw, gumRaw);

  // Split teeth and gums by Y around midY.
  const teeth = { upper: [], lower: [] };
  teethRaw.forEach((t) => {
    teeth[t.center.y >= midY ? 'upper' : 'lower'].push({
      name: t.name,
      node: t.node,
      center: t.center,
    });
  });

  const gums = { upper: null, lower: null };
  gumRaw.forEach((g) => {
    const arch = g.center.y >= midY ? 'upper' : 'lower';
    // If multiple meshes match for the same arch (shouldn't normally happen),
    // the first wins. The brief states 1 gum mesh per arch.
    if (!gums[arch]) gums[arch] = { name: g.name, node: g.node };
  });

  // Sort teeth left-to-right (X ascending) so socket numbering is intuitive
  // (Upper_01 = patient's right, Upper_14 = patient's left).
  teeth.upper.sort((a, b) => a.center.x - b.center.x);
  teeth.lower.sort((a, b) => a.center.x - b.center.x);

  // Attach display labels after sort so index matches the visible card order.
  teeth.upper.forEach((t, i) => { t.label = UPPER_LABELS[i + 1] ?? null; });
  teeth.lower.forEach((t, i) => { t.label = LOWER_LABELS[i + 1] ?? null; });

  // Derive sockets from each tooth's canonical world transform.
  const sockets = { upper: {}, lower: {} };
  ['upper', 'lower'].forEach((arch) => {
    const archCap = arch === 'upper' ? 'Upper' : 'Lower';
    teeth[arch].forEach((t, i) => {
      const socketName = `Socket_${archCap}_${String(i + 1).padStart(2, '0')}`;
      sockets[arch][socketName] = decomposeWorld(t.node);
    });
  });

  return { gums, teeth, sockets };
}

/**
 * Flatten per-arch sockets into a single { name -> {position, rotation} }
 * map for Scene's snap lookup.
 */
export function flattenSockets(socketsByArch) {
  return { ...socketsByArch.upper, ...socketsByArch.lower };
}

/**
 * Floating "stage" pose — where the currently-selected unplaced tooth
 * appears, above (upper) or below (lower) the visible gum.
 */
export function buildStagePose(arch, gumBounds) {
  if (!gumBounds) return { position: [0, 0, 0], rotation: [0, 0, 0] };
  const [cx, cy, cz] = gumBounds.center;
  const r = gumBounds.radius;
  const yOffset = arch === 'upper' ? r * 0.9 : -r * 0.9;
  return {
    position: [cx, cy + yOffset, cz + r * 0.3],
    rotation: [0, 0, 0],
  };
}

/**
 * Replace gum + tooth materials in-place. The GLB ships every mesh with the
 * same shared white/metallic material; we swap each affected mesh to a
 * unique MeshStandardMaterial with sensible PBR for that tissue type.
 *
 * Mutates nodes — call once after buildSceneIndex, before rendering.
 */
export function applyDentalMaterials(dental) {
  ['upper', 'lower'].forEach((arch) => {
    const gum = dental.gums[arch];
    if (gum) {
      gum.node.material = makeGumMaterial();
      // Gum is rendered via <primitive>, which doesn't accept the
      // castShadow / receiveShadow JSX props, so we set them on the node.
      gum.node.castShadow = true;
      gum.node.receiveShadow = true;
    }
    dental.teeth[arch].forEach((t) => {
      t.node.material = makeToothMaterial();
      t.node.castShadow = true;
      t.node.receiveShadow = true;
    });
  });
}

function makeGumMaterial() {
  // Soft tissue: mostly diffuse with a faint sheen, plus a warm emissive to
  // imply subsurface scatter without paying for transmission. Keep roughness
  // mid-high so any IBL reflection stays blurred and doesn't desaturate the
  // pink base color.
  return new THREE.MeshStandardMaterial({
    color: new THREE.Color(GUM_COLOR),
    roughness: 0.65,
    metalness: 0.0,
    emissive: new THREE.Color('#6a2424'),
    emissiveIntensity: 0.12,
  });
}

function makeToothMaterial() {
  // Enamel: glossy ivory + clearcoat for the wet "lacquer" highlight that
  // sells real teeth. MeshPhysicalMaterial is a superset of standard, so
  // the cost is one extra GBuffer pass for clearcoat — fine for ~14 meshes.
  const m = new THREE.MeshPhysicalMaterial({
    color: new THREE.Color(TOOTH_COLOR),
    roughness: 0.32,
    metalness: 0.0,
    clearcoat: 0.55,
    clearcoatRoughness: 0.12,
    sheen: 0.15,
    sheenRoughness: 0.6,
    sheenColor: new THREE.Color('#fff5dd'),
  });
  return m;
}

export function computeGumBounds(gumNode) {
  if (!gumNode) return null;
  const box = new THREE.Box3().setFromObject(gumNode);
  const sphere = new THREE.Sphere();
  box.getBoundingSphere(sphere);
  return { center: sphere.center.toArray(), radius: sphere.radius };
}

function decomposeWorld(object3D) {
  const pos = new THREE.Vector3();
  const quat = new THREE.Quaternion();
  const scale = new THREE.Vector3();
  object3D.matrixWorld.decompose(pos, quat, scale);
  const euler = new THREE.Euler().setFromQuaternion(quat, 'XYZ');
  return {
    position: [pos.x, pos.y, pos.z],
    rotation: [euler.x, euler.y, euler.z],
  };
}

function computeArchMidY(teethRaw, gumRaw) {
  if (teethRaw.length >= 2) {
    const ys = teethRaw.map((t) => t.center.y).sort((a, b) => a - b);
    return (ys[0] + ys[ys.length - 1]) / 2;
  }
  if (gumRaw.length >= 2) {
    const ys = gumRaw.map((g) => g.center.y).sort((a, b) => a - b);
    return (ys[0] + ys[ys.length - 1]) / 2;
  }
  return 0;
}
