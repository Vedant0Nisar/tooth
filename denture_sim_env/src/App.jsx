import { Suspense, useCallback, useMemo, useState, useEffect } from 'react';
import { useGLTF } from '@react-three/drei';
import Scene from './components/Scene.jsx';
import PlacementModal from './components/PlacementModal.jsx';
import TransformToggle from './components/TransformToggle.jsx';
import HUD from './components/HUD.jsx';
import ToothStrip from './components/ToothStrip.jsx';
import ActionMenu from './components/ActionMenu.jsx';
import {
  buildSceneIndex,
  flattenSockets,
  applyDentalMaterials,
} from './lib/dentalIndex.js';

const MODEL_URL = './jaw_model.glb';
useGLTF.preload(MODEL_URL, './draco/');

const ARCH_LABELS = { upper: 'Upper Jaw', lower: 'Lower Jaw' };

/**
 * App owns interaction state for the entire placement workflow:
 *   - selectedTooth: which tooth the user has focused (from the strip OR by
 *     re-clicking a placed tooth in 3D)
 *   - placements: { toothName -> socketName } — derived occupiedSockets keeps
 *     the modal from offering an already-taken slot
 *   - transforms: per-tooth absolute world poses, populated only after a
 *     TransformControls drag (otherwise Scene falls back to the socket pose)
 *   - arch: which jaw is currently visible (hardcoded to 'upper' for the
 *     first-pass UX; lower-arch toggle can plug in here later)
 *
 * The GLB is loaded at this level so the bottom card strip can list teeth
 * without a callback round-trip from Scene.
 */
function DentalApp() {
  const { scene, nodes } = useGLTF(MODEL_URL, './draco/');

  // One-shot categorization of the GLTF; stable across renders.
  const dental = useMemo(() => {
    const d = buildSceneIndex(scene, nodes);
    // Swap the GLB's default white/metallic material for proper gum + tooth
    // PBR before any mesh hits the renderer.
    applyDentalMaterials(d);
    return d;
  }, [scene, nodes]);
  // Flat lookup used by Scene to snap a tooth onto its chosen socket.
  const socketTransforms = useMemo(
    () => flattenSockets(dental.sockets),
    [dental]
  );

  // First-pass UX: only the upper arch is shown. Easy to extend to a toggle
  // later — pass setArch into a UI control and ToothStrip + Scene both react.
  const [arch, setArch] = useState('upper');
  const [upperCompleted, setUpperCompleted] = useState(false);

  const archGum = dental.gums[arch];
  const archTeeth = dental.teeth[arch];
  const archSocketNames = useMemo(
    () => Object.keys(dental.sockets[arch] || {}),
    [dental, arch]
  );

  const [selectedTooth, setSelectedTooth] = useState(null);
  const [placements, setPlacements] = useState({});
  const [transforms, setTransforms] = useState({});
  const [transformMode, setTransformMode] = useState('translate');
  const [isTransforming, setIsTransforming] = useState(false);
  const [isTransparent, setIsTransparent] = useState(false);
  const [incorrectTeeth, setIncorrectTeeth] = useState(new Set());
  const [lowerCompleted, setLowerCompleted] = useState(false);

  const occupiedSockets = useMemo(
    () => new Set(Object.values(placements)),
    [placements]
  );

  const handleCheckArch = useCallback(() => {
    const archCap = arch === 'upper' ? 'Upper' : 'Lower';
    const errors = new Set();
    archTeeth.forEach((t, i) => {
      const expected = `Socket_${archCap}_${String(i + 1).padStart(2, '0')}`;
      if (placements[t.name] !== expected) {
        errors.add(t.name);
      }
    });

    if (errors.size === 0) {
      setIncorrectTeeth(new Set());
      if (arch === 'upper') {
        setUpperCompleted(true);
        setArch('lower');
        setSelectedTooth(null);
      } else {
        setLowerCompleted(true);
        setSelectedTooth(null);
      }
    } else {
      setIncorrectTeeth(errors);
    }
  }, [arch, archTeeth, placements]);

  // Clear errors if user makes a new placement
  useEffect(() => {
    if (incorrectTeeth.size > 0) {
      setIncorrectTeeth(new Set());
    }
  }, [placements]);

  // Modal opens when the focused tooth has no socket yet; gizmo when it does.
  const isModalOpen = selectedTooth != null && !placements[selectedTooth];
  const isEditingPlaced = selectedTooth != null && !!placements[selectedTooth];

  const handleSelectTooth = useCallback((toothName) => {
    setSelectedTooth(toothName);
  }, []);

  const handleDeselect = useCallback(() => {
    setSelectedTooth(null);
  }, []);

  const handleConfirmPlacement = useCallback(
    (socketName) => {
      if (!selectedTooth) return;
      setPlacements((prev) => ({ ...prev, [selectedTooth]: socketName }));
      // Drop any prior fine-tune offsets so the tooth snaps cleanly to the
      // socket world transform — Scene falls back to socket pose when the
      // transforms entry is absent.
      setTransforms((prev) => {
        if (!(selectedTooth in prev)) return prev;
        const copy = { ...prev };
        delete copy[selectedTooth];
        return copy;
      });
      setSelectedTooth(null);
    },
    [selectedTooth]
  );

  const handleTransformChange = useCallback((toothName, next) => {
    setTransforms((prev) => ({
      ...prev,
      [toothName]: { ...prev[toothName], ...next },
    }));
  }, []);

  const handleResetPose = useCallback((toothName) => {
    setTransforms((prev) => {
      if (!(toothName in prev)) return prev;
      const copy = { ...prev };
      delete copy[toothName];
      return copy;
    });
  }, []);

  const handleResetTooth = useCallback((toothName) => {
    setPlacements((prev) => {
      const copy = { ...prev };
      delete copy[toothName];
      return copy;
    });
    setTransforms((prev) => {
      const copy = { ...prev };
      delete copy[toothName];
      return copy;
    });
    setSelectedTooth(null);
  }, []);

  return (
    <div className="relative h-full w-full overflow-hidden bg-slate-950">
      {/* Ambient backdrop — soft radial glows give the dark canvas depth
          without competing with the 3D model. Pointer-events disabled so
          they never interfere with input. */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_80%_60%_at_50%_-10%,rgba(99,102,241,0.18),transparent_70%)]" />
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_60%_40%_at_85%_110%,rgba(236,72,153,0.10),transparent_70%)]" />
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_50%_50%_at_15%_110%,rgba(34,211,238,0.07),transparent_70%)]" />

      <Scene
        arch={arch}
        gum={archGum}
        teeth={archTeeth}
        dental={dental}
        upperCompleted={upperCompleted}
        socketTransforms={socketTransforms}
        selectedTooth={selectedTooth}
        placements={placements}
        incorrectTeeth={incorrectTeeth}
        occupiedSockets={occupiedSockets}
        archSocketNames={archSocketNames}
        transforms={transforms}
        transformMode={transformMode}
        isTransforming={isTransforming}
        isModalOpen={isModalOpen}
        isTransparent={isTransparent}
        onSelectTooth={handleSelectTooth}
        onTransformStart={() => setIsTransforming(true)}
        onTransformEnd={() => setIsTransforming(false)}
        onTransformChange={handleTransformChange}
      />

      {/* Check Arch Button */}
      {occupiedSockets.size === archTeeth.length && !isModalOpen && !lowerCompleted && (
        <div className="absolute bottom-40 left-1/2 -translate-x-1/2 z-30">
          <button
            onClick={handleCheckArch}
            className="rounded-full bg-cyan-500 px-6 py-2.5 text-[13px] font-bold text-white shadow-[0_0_20px_rgba(34,211,238,0.4)] transition hover:bg-cyan-400 hover:scale-105 active:scale-95"
          >
            Check Placement
          </button>
        </div>
      )}

      {/* Success Message */}
      {lowerCompleted && (
        <div className="absolute top-20 left-1/2 -translate-x-1/2 z-30 flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-500/20 px-6 py-3 text-[14px] font-bold text-emerald-300 shadow-[0_0_30px_rgba(16,185,129,0.3)] backdrop-blur-xl">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="h-5 w-5"><path d="M20 6L9 17l-5-5" /></svg>
          Simulation Complete!
        </div>
      )}

      <ActionMenu
        isTransparent={isTransparent}
        onToggleTransparent={() => setIsTransparent((v) => !v)}
        selectedTooth={selectedTooth}
        isEditingPlaced={isEditingPlaced}
        onDeselect={handleDeselect}
        onResetPose={handleResetPose}
        onResetTooth={handleResetTooth}
      />

      <HUD
        selectedTooth={selectedTooth}
        placements={placements}
        totalTeeth={archTeeth.length}
        archLabel={ARCH_LABELS[arch]}
      />

      {isEditingPlaced && (
        <TransformToggle mode={transformMode} onChange={setTransformMode} />
      )}

      <ToothStrip
        teeth={archTeeth}
        selectedTooth={selectedTooth}
        placements={placements}
        incorrectTeeth={incorrectTeeth}
        archLabel={ARCH_LABELS[arch]}
        onSelect={handleSelectTooth}
      />

      {isModalOpen && (
        <PlacementModal
          toothName={selectedTooth}
          archLabel={ARCH_LABELS[arch]}
          availableSockets={archSocketNames}
          occupiedSockets={occupiedSockets}
          onConfirm={handleConfirmPlacement}
          onCancel={handleDeselect}
        />
      )}
    </div>
  );
}

function LoadingOverlay() {
  return (
    <div className="relative flex h-full w-full items-center justify-center overflow-hidden bg-slate-950 text-slate-200">
      {/* Same ambient backdrop as the main view for visual continuity */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_70%_60%_at_50%_30%,rgba(99,102,241,0.18),transparent_70%)]" />
      <div className="relative flex flex-col items-center gap-4">
        <div className="flex items-center gap-2.5">
          <span className="relative flex h-2.5 w-2.5">
            <span className="absolute inline-flex h-full w-full animate-pulse-glow rounded-full bg-cyan-400" />
            <span className="h-2.5 w-2.5 rounded-full bg-cyan-400" />
          </span>
          <span className="text-[11px] font-semibold uppercase tracking-[0.22em] text-slate-300">
            Loading dental model
          </span>
        </div>
        <div className="h-1 w-48 overflow-hidden rounded-full bg-white/5">
          <div className="h-full w-1/3 animate-[fadeIn_400ms_ease-out] rounded-full bg-gradient-to-r from-cyan-400 via-sky-400 to-violet-400 shadow-[0_0_12px_rgba(34,211,238,0.6)]" />
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <Suspense fallback={<LoadingOverlay />}>
      <DentalApp />
    </Suspense>
  );
}
