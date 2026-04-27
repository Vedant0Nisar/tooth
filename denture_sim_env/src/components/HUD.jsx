import { useState } from 'react';

const RADIUS = 14;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

function CircleProgress({ placed, total }) {
  const pct = total > 0 ? placed / total : 0;
  const offset = CIRCUMFERENCE * (1 - pct);
  return (
    <div className="relative flex h-10 w-10 items-center justify-center">
      <svg width="40" height="40" viewBox="0 0 40 40" className="-rotate-90">
        {/* Track */}
        <circle cx="20" cy="20" r={RADIUS} fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="3" />
        {/* Arc */}
        <circle
          cx="20" cy="20" r={RADIUS}
          fill="none"
          stroke="url(#prog)"
          strokeWidth="3"
          strokeLinecap="round"
          strokeDasharray={CIRCUMFERENCE}
          strokeDashoffset={offset}
          style={{ transition: 'stroke-dashoffset 0.5s ease-out' }}
        />
        <defs>
          <linearGradient id="prog" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#22d3ee" />
            <stop offset="100%" stopColor="#818cf8" />
          </linearGradient>
        </defs>
      </svg>
      <span className="absolute flex flex-col items-center leading-none">
        <span className="font-mono text-[10px] font-semibold text-cyan-300">{placed}</span>
        <span className="font-mono text-[8px] text-slate-500">{total}</span>
      </span>
    </div>
  );
}

/**
 * HUD
 *
 * Top-left status panel. On phones it collapses to a compact chip showing
 * progress; tapping the chip expands the full panel. On tablet+ (>= sm) the
 * full panel is always visible.
 */
export default function HUD({
  selectedTooth,
  placements,
  totalTeeth,
  archLabel,
}) {
  const placedCount = Object.keys(placements).length;
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="pointer-events-none absolute left-3 top-3 z-20 sm:left-6 sm:top-6">
      {/* Mobile: compact chip (hidden on sm+). Toggles the expanded panel. */}
      <button
        type="button"
        onClick={() => setExpanded((v) => !v)}
        className="panel-pill pointer-events-auto flex items-center gap-2 px-3 py-1.5 text-[11px] font-medium text-slate-200 sm:hidden"
        aria-expanded={expanded}
        aria-label="Toggle status panel"
      >
        <span className="relative flex h-1.5 w-1.5">
          <span className="absolute inline-flex h-full w-full animate-pulse-glow rounded-full bg-cyan-400" />
          <span className="h-1.5 w-1.5 rounded-full bg-cyan-400" />
        </span>
        <span className="font-mono tabular-nums text-cyan-300">
          {placedCount}<span className="text-slate-500">/{totalTeeth}</span>
        </span>
        <span className="text-slate-500">·</span>
        <span className="max-w-[80px] truncate text-slate-300">
          {selectedTooth ?? archLabel}
        </span>
      </button>

      {/* Full panel: always visible on sm+; mobile shows it only when chip
          is toggled open. */}
      <div
        className={[
          'panel-glass pointer-events-auto mt-2 w-[calc(100vw-1.5rem)] max-w-[300px] animate-fade-in p-4 sm:mt-0 sm:block sm:w-[280px] sm:p-5',
          expanded ? 'block' : 'hidden sm:block',
        ].join(' ')}
      >
        {/* Title row — hidden on the mobile expanded view to save vertical
            space; the compact chip already conveys the live status. */}
        <div className="hidden items-center gap-2.5 sm:flex">
          <div className="relative flex h-2 w-2 items-center justify-center">
            <span className="absolute h-full w-full animate-pulse-glow rounded-full bg-cyan-400" />
            <span className="h-2 w-2 rounded-full bg-cyan-400" />
          </div>
          <h1 className="text-[13px] font-semibold tracking-tight text-white">
            Dental Placement Studio
          </h1>
        </div>

        <p className="hidden text-[11.5px] leading-relaxed text-slate-400 sm:mt-2 sm:block">
          Pick a tooth from the strip, choose a socket from the popup, then
          click a placed tooth to fine-tune.
        </p>

        {/* Progress section */}
        <div className="sm:mt-5">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-medium text-slate-300">{archLabel}</span>
            <CircleProgress placed={placedCount} total={totalTeeth} />
          </div>
        </div>

        {/* Selected tooth name indicator */}
        {selectedTooth && (
          <div className="mt-4 animate-scale-in border-t border-white/[0.06] pt-3 sm:mt-5 sm:pt-4">
            <div className="text-[10px] font-medium uppercase tracking-[0.18em] text-slate-500">
              Selection
            </div>
            <div className="mt-1.5 flex items-center gap-2">
              <span className="h-1.5 w-1.5 rounded-full bg-cyan-400 shadow-[0_0_8px_rgba(34,211,238,0.8)]" />
              <span className="truncate font-mono text-[12px] text-white">
                {selectedTooth}
              </span>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
