import { useEffect, useMemo, useRef, useState } from 'react';
import * as THREE from 'three';

const HIGHLIGHT_COLOR = new THREE.Color('#22d3ee');
const HOVER_COLOR = new THREE.Color('#fde68a');
const PLACED_TINT = new THREE.Color('#86efac');
const NEUTRAL_BLACK = new THREE.Color('#000000');

/**
 * Tooth
 *
 * Wraps a single tooth mesh. Owns:
 *   - a cloned material instance, so emissive highlighting is local to this
 *     tooth (without mutating any sibling material).
 *   - the actual <mesh> ref, which the parent collects so TransformControls
 *     can attach to it when this tooth is selected for fine-tuning.
 *
 * The mesh's transform is fully controlled by the parent (tray vs socket vs
 * fine-tuned pose). When TransformControls drags the mesh, three.js mutates
 * mesh.position/rotation directly; the parent reads those out on drag-end.
 */
export default function Tooth({
  name,
  node,
  position,
  rotation,
  isSelected,
  isPlaced,
  disablePointer,
  isTransparent,
  transparentOpacity = 0.45,
  registerRef,
  onClick,
}) {
  const meshRef = useRef();
  const [hovered, setHovered] = useState(false);

  // One material clone per tooth keeps emissive tweaks isolated.
  const material = useMemo(() => {
    const cloned = node.material ? node.material.clone() : new THREE.MeshStandardMaterial();
    cloned.emissive = NEUTRAL_BLACK.clone();
    cloned.emissiveIntensity = 0;
    return cloned;
  }, [node]);

  // Drive emissive based on selection / hover / placement state. We
  // proportionally damp emissive when transparency is on, otherwise the
  // additive emissive term keeps the tooth looking opaque even at low alpha.
  useEffect(() => {
    if (!material) return;
    const damp = isTransparent ? 0.35 : 1;
    if (isSelected) {
      material.emissive.copy(HIGHLIGHT_COLOR);
      material.emissiveIntensity = 0.55 * damp;
    } else if (hovered && !disablePointer) {
      material.emissive.copy(HOVER_COLOR);
      material.emissiveIntensity = 0.35 * damp;
    } else if (isPlaced) {
      material.emissive.copy(PLACED_TINT);
      material.emissiveIntensity = 0.08 * damp;
    } else {
      material.emissive.copy(NEUTRAL_BLACK);
      material.emissiveIntensity = 0;
    }
  }, [isSelected, hovered, isPlaced, disablePointer, isTransparent, material]);

  // Free the cloned material when this tooth unmounts to avoid leaks.
  useEffect(() => {
    return () => {
      material?.dispose?.();
    };
  }, [material]);

  // Mirror the App-level transparency toggle onto this tooth's cloned
  // material. depthWrite goes off in transparent mode so teeth don't punch
  // depth-buffer holes that hide neighbours behind them. Clearcoat is also
  // damped — full clearcoat reflections read as a glossy opaque layer even
  // when the diffuse term is alpha-blended away.
  useEffect(() => {
    if (!material) return;
    material.transparent = isTransparent;
    material.opacity = isTransparent ? transparentOpacity : 1.0;
    material.depthWrite = !isTransparent;
    if ('clearcoat' in material) {
      // Cache the original so we can restore it cleanly.
      if (material.userData.baseClearcoat === undefined) {
        material.userData.baseClearcoat = material.clearcoat;
      }
      material.clearcoat = isTransparent ? 0 : material.userData.baseClearcoat;
    }
    if ('sheen' in material) {
      if (material.userData.baseSheen === undefined) {
        material.userData.baseSheen = material.sheen;
      }
      material.sheen = isTransparent ? 0 : material.userData.baseSheen;
    }
    material.needsUpdate = true;
  }, [isTransparent, transparentOpacity, material]);

  // Surface our mesh ref to the parent so TransformControls can target it.
  useEffect(() => {
    registerRef?.(name, meshRef.current);
    return () => registerRef?.(name, null);
  }, [name, registerRef]);

  return (
    <mesh
      ref={meshRef}
      name={name}
      geometry={node.geometry}
      material={material}
      castShadow
      receiveShadow
      // R3F reconciles position/rotation props onto the underlying Object3D,
      // so writes to these props (e.g., a fresh socket snap or a committed
      // gizmo drag) flow through automatically.
      position={position}
      rotation={rotation}
      // Preserve the tooth's authored scale; only translation/rotation are
      // overridden by the parent.
      scale={[node.scale.x, node.scale.y, node.scale.z]}
      onClick={(e) => {
        if (disablePointer) return;
        e.stopPropagation();
        onClick(name);
      }}
      onPointerOver={(e) => {
        if (disablePointer) return;
        e.stopPropagation();
        setHovered(true);
        document.body.style.cursor = 'pointer';
      }}
      onPointerOut={() => {
        setHovered(false);
        document.body.style.cursor = 'default';
      }}
    />
  );
}
