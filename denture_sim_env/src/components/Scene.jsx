import { Suspense, useEffect, useMemo, useRef } from 'react';

const isMobile =
  /iPhone|iPad|iPod|Android/i.test(navigator.userAgent) ||
  window.innerWidth < 768;
import { Canvas, useThree } from '@react-three/fiber';
import {
  Html,
  OrbitControls,
  TransformControls,
  Billboard,
  Text,
} from '@react-three/drei';
import { computeGumBounds, buildStagePose } from '../lib/dentalIndex.js';
import Tooth from './Tooth.jsx';

/**
 * Inner content — needs to live under <Canvas> to use useThree.
 *
 * Scene rendering rules:
 *   - Only the active arch's gum is drawn.
 *   - A tooth is drawn iff it is placed OR it is the current selection.
 *   - Pose priority per tooth: fine-tune > socket-snap > stage (floating).
 */
// 45% opacity = 55% transparent — readable as "x-ray" without making the
// model invisible. Tweak here if the user wants a different mix.
const TRANSPARENT_OPACITY = 0.45;

function DentalSceneContent({
  arch,
  gum,
  teeth,
  dental,
  upperCompleted,
  socketTransforms,
  selectedTooth,
  placements,
  transforms,
  transformMode,
  isTransforming,
  isModalOpen,
  isTransparent,
  onSelectTooth,
  onTransformStart,
  onTransformEnd,
  onTransformChange,
}) {
  const gumBounds = useMemo(() => computeGumBounds(gum?.node), [gum]);
  const stagePose = useMemo(() => buildStagePose(arch, gumBounds), [arch, gumBounds]);

  const toothMeshRefs = useRef({});
  const registerToothRef = (name, mesh) => {
    if (mesh) toothMeshRefs.current[name] = mesh;
    else delete toothMeshRefs.current[name];
  };

  // Drive the gum's translucency from the App-level toggle. The gum is
  // rendered via <primitive>, so we mutate its material directly. Teeth
  // each clone their own material in Tooth.jsx and respond to the same
  // `isTransparent` prop there.
  useEffect(() => {
    const m = gum?.node?.material;
    if (!m) return;
    m.transparent = isTransparent;
    m.opacity = isTransparent ? TRANSPARENT_OPACITY : 1.0;
    // Disabling depthWrite while transparent prevents this mesh from
    // occluding the teeth behind it through the depth buffer.
    m.depthWrite = !isTransparent;
    m.needsUpdate = true;
  }, [gum, isTransparent]);

  useEffect(() => {
    // If we are on the lower arch and upper is completed, make upper gum transparent
    if (arch === 'lower' && upperCompleted && dental?.gums?.upper) {
      const um = dental.gums.upper.node?.material;
      if (um) {
        um.transparent = true;
        um.opacity = TRANSPARENT_OPACITY;
        um.depthWrite = false;
        um.needsUpdate = true;
      }
    }
  }, [arch, upperCompleted, dental]);

  const { camera } = useThree();
  useEffect(() => {
    if (!gumBounds) return;
    const [cx, cy, cz] = gumBounds.center;
    const dist = gumBounds.radius * 3.4;
    camera.position.set(cx, cy + gumBounds.radius * 0.2, cz + dist);
    camera.near = Math.max(0.01, gumBounds.radius * 0.01);
    camera.far = dist * 10;
    camera.lookAt(cx, cy, cz);
    camera.updateProjectionMatrix();
  }, [camera, gumBounds]);

  const resolvePose = (name) => {
    const placedSocket = placements[name];
    if (transforms[name]) return transforms[name];
    if (placedSocket && socketTransforms[placedSocket]) {
      return socketTransforms[placedSocket];
    }
    if (selectedTooth === name) return stagePose;
    return null;
  };

  const controlledMesh =
    selectedTooth && placements[selectedTooth]
      ? toothMeshRefs.current[selectedTooth]
      : null;

  const commitTransform = () => {
    if (!selectedTooth) return;
    const mesh = toothMeshRefs.current[selectedTooth];
    if (!mesh) return;
    onTransformChange(selectedTooth, {
      position: [mesh.position.x, mesh.position.y, mesh.position.z],
      rotation: [mesh.rotation.x, mesh.rotation.y, mesh.rotation.z],
    });
  };

  return (
    <>
      <ambientLight intensity={0.35} />
      <hemisphereLight color="#fff0f0" groundColor="#1a0808" intensity={0.45} />
      <directionalLight
        position={[10, 18, 12]}
        intensity={1.25}
        castShadow={!isMobile}
        shadow-mapSize-width={isMobile ? 512 : 2048}
        shadow-mapSize-height={isMobile ? 512 : 2048}
        shadow-bias={-0.0005}
        shadow-camera-near={0.5}
        shadow-camera-far={300}
        shadow-camera-left={-80}
        shadow-camera-right={80}
        shadow-camera-top={80}
        shadow-camera-bottom={-80}
      />
      <directionalLight position={[-10, 8, -6]} intensity={0.55} />
      <directionalLight position={[0, -8, 10]} intensity={0.3} />

      {gum && <primitive object={gum.node} />}
      {arch === 'lower' && upperCompleted && dental?.gums?.upper && (
        <primitive object={dental.gums.upper.node} />
      )}

      {/* Render active arch teeth */}
      {teeth.map(({ name, node }) => {
        const pose = resolvePose(name);
        if (!pose) return null;
        return (
          <Tooth
            key={name}
            name={name}
            node={node}
            position={pose.position}
            rotation={pose.rotation}
            isSelected={selectedTooth === name}
            isPlaced={!!placements[name]}
            disablePointer={isModalOpen}
            isTransparent={isTransparent}
            transparentOpacity={TRANSPARENT_OPACITY}
            registerRef={registerToothRef}
            onClick={onSelectTooth}
          />
        );
      })}

      {/* Render completed upper teeth transparently when on lower arch */}
      {arch === 'lower' && upperCompleted && dental?.teeth?.upper?.map(({ name, node }) => {
        const pose = placements[name] ? socketTransforms[placements[name]] : null;
        if (!pose) return null;
        return (
          <Tooth
            key={name + '_ghost'}
            name={name}
            node={node}
            position={pose.position}
            rotation={pose.rotation}
            isSelected={false}
            isPlaced={true}
            disablePointer={true}
            isTransparent={true}
            transparentOpacity={TRANSPARENT_OPACITY}
            registerRef={() => {}}
            onClick={() => {}}
          />
        );
      })}

      {controlledMesh && (
        <TransformControls
          object={controlledMesh}
          mode={transformMode}
          size={0.8}
          onMouseDown={onTransformStart}
          onMouseUp={() => {
            commitTransform();
            onTransformEnd();
          }}
        />
      )}

      {/* Render socket numbers */}
      {Object.keys(dental.sockets[arch] || {}).map((socketName) => {
        // Check if this socket is already occupied by any tooth
        if (Object.values(placements).includes(socketName)) return null;
        
        const pose = socketTransforms[socketName];
        if (!pose) return null;
        
        const num = parseInt(socketName.split('_').pop(), 10);
        const isUpper = socketName.includes('Upper');
        
        // Move the number slightly outside the gum mesh so it's always visible
        const yOffset = isUpper ? 0.45 : -0.45;
        const zOffset = 0.3;

        return (
          <Billboard
            key={socketName}
            position={[pose.position[0], pose.position[1] + yOffset, pose.position[2] + zOffset]}
          >
            <Text
              fontSize={0.5}
              color="white"
              anchorX="center"
              anchorY="middle"
              outlineWidth={0.07}
              outlineColor="#22d3ee"
              opacity={isModalOpen ? 0.35 : 1}
            >
              {num}
            </Text>
          </Billboard>
        );
      })}

      <OrbitControls
        makeDefault
        enabled={!isTransforming && !isModalOpen}
        target={gumBounds ? gumBounds.center : [0, 0, 0]}
        enableDamping
        dampingFactor={0.08}
      />
    </>
  );
}

export default function Scene(props) {
  return (
    <Canvas
      shadows={!isMobile}
      dpr={isMobile ? 1 : [1, 2]}
      camera={{ position: [0, 5, 30], fov: 45, near: 0.1, far: 2000 }}
      gl={{ antialias: !isMobile, alpha: true, preserveDrawingBuffer: false }}
    >
      {/* No <color attach="background"> — Canvas is transparent so the
          App-level ambient radial backdrop shows behind the model, matching
          the loading-screen palette. */}
      <Suspense
        fallback={
          <Html center>
            <div className="flex items-center gap-2 rounded-full border border-white/[0.08] bg-slate-900/80 px-4 py-1.5 text-[11px] font-medium text-slate-300 shadow-lg backdrop-blur-xl">
              <span className="relative flex h-1.5 w-1.5">
                <span className="absolute inline-flex h-full w-full animate-pulse-glow rounded-full bg-cyan-400" />
                <span className="h-1.5 w-1.5 rounded-full bg-cyan-400" />
              </span>
              Preparing scene
            </div>
          </Html>
        }
      >
        <DentalSceneContent {...props} />
      </Suspense>
    </Canvas>
  );
}
