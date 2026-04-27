# Dental 3D Placement Studio

An interactive 3D dental simulation app for visualizing and placing individual teeth onto a jaw model. Built with React, Three.js, and React Three Fiber — fully optimized for mobile.

---

## Features

- **3D jaw model** rendered in real-time with physically-based materials (enamel clearcoat, gum subsurface scatter approximation)
- **Tooth placement** — pick a tooth from the strip, assign it to a socket, then fine-tune position and rotation with transform controls
- **X-ray / transparency mode** — see through the gum to inspect tooth roots and alignment
- **Hamburger action menu** — animated dropdown with circle icons for transparency toggle, deselect, reset pose, and free socket
- **Circular progress indicator** — compact donut ring showing placed / total teeth count
- **Anatomical tooth labels** — full 14-tooth upper arch naming (Second Molar → Central Incisor → Second Molar)
- **Mobile-first performance** — adaptive rendering quality (DPR, shadows, antialiasing) based on device

---

## Tech Stack

| Layer | Library |
|---|---|
| UI framework | React 18 |
| 3D rendering | Three.js + React Three Fiber |
| 3D helpers | @react-three/drei |
| Styling | Tailwind CSS |
| Build tool | Vite |
| Model compression | @gltf-transform/cli (Draco) |

---

## Getting Started

### Prerequisites

- Node.js 18+
- npm

### Install

```bash
npm install
```

### Run (development)

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.  
To test on mobile, use the `Network` URL printed in the terminal.

### Build (production)

```bash
npm run build
npm run preview
```

---

## Model Optimization

The raw GLB (`dental_model.glb`, ~56 MB) is compressed with Draco to ~5.7 MB.  
To recompress after replacing the model:

```bash
npx gltf-transform draco public/dental_model.glb public/dental_model_draco.glb
```

Draco decoder files are served from `public/draco/`.

---

## Project Structure

```
src/
├── components/
│   ├── Scene.jsx           # Three.js canvas + lighting + OrbitControls
│   ├── Tooth.jsx           # Individual tooth mesh with material cloning
│   ├── ToothStrip.jsx      # Horizontal scrollable tooth card strip
│   ├── HUD.jsx             # Top-left status panel + circular progress ring
│   ├── ActionMenu.jsx      # Hamburger menu with animated dropdown
│   ├── PlacementModal.jsx  # Socket selection modal
│   ├── TransformToggle.jsx # Move / Rotate segmented control
│   └── TransparencyToggle.jsx
├── lib/
│   └── dentalIndex.js      # GLB parsing, arch classification, material setup
├── App.jsx                 # Root — state management + layout
└── index.css               # Global styles + animation keyframes
public/
├── dental_model_draco.glb  # Draco-compressed 3D model
└── draco/                  # Draco WASM decoder
```

---

## Tooth Naming (Upper Arch)

| # | Name |
|---|---|
| 1 | Second Molar |
| 2 | First Molar |
| 3 | Second Bicuspid |
| 4 | First Bicuspid |
| 5 | Canine |
| 6 | Lateral Incisor |
| 7 | Central Incisor |
| 8 | Central Incisor |
| 9 | Lateral Incisor |
| 10 | Canine (Cuspid) |
| 11 | First Bicuspid |
| 12 | Second Bicuspid |
| 13 | First Molar |
| 14 | Second Molar |

To rename teeth, edit `UPPER_LABELS` / `LOWER_LABELS` in `src/lib/dentalIndex.js`.

---

## Mobile Optimizations

- Draco-compressed GLB (56 MB → 5.7 MB, **90% smaller**)
- Code-split vendor chunks (React, Three.js, Fiber loaded in parallel)
- Mobile-adaptive rendering: shadows off, DPR capped at 1×, antialiasing off
- GPU-composited CSS animations (`will-change: transform, opacity`)
- No CDN HDRI fetch — environment replaced with direct lights

---

## License

MIT
