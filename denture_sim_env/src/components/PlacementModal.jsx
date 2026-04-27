import { useMemo, useState } from 'react';

/**
 * PlacementModal
 *
 * Modern dialog for choosing the destination socket. Sockets are filtered
 * to the active arch (so an upper tooth can only land in an upper socket).
 * Already-occupied sockets are disabled — that's what guarantees no two
 * teeth share a slot.
 */
export default function PlacementModal({
  toothName,
  archLabel,
  availableSockets,
  occupiedSockets,
  onConfirm,
  onCancel,
}) {
  const [pick, setPick] = useState(null);

  const sortedSockets = useMemo(
    () => [...availableSockets].sort((a, b) => a.localeCompare(b)),
    [availableSockets]
  );

  const canConfirm = pick && !occupiedSockets.has(pick);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/65 px-3 backdrop-blur-md animate-fade-in sm:px-4"
      role="dialog"
      aria-modal="true"
    >
      <div className="panel-glass panel-glass--solid w-[min(520px,100%)] animate-scale-in overflow-hidden">
        {/* Header */}
        <div className="relative border-b border-white/[0.06] px-4 py-4 sm:px-6 sm:py-5">
          <div className="flex items-center gap-2.5">
            <div className="h-1 w-6 rounded-full bg-gradient-to-r from-cyan-400 to-violet-400" />
            <span className="text-[10px] font-semibold uppercase tracking-[0.2em] text-slate-400">
              Placement
            </span>
          </div>
          <h2 className="mt-2 text-[17px] font-semibold tracking-tight text-white">
            Choose a socket for this tooth
          </h2>
          <div className="mt-1.5 flex items-center gap-2 text-[11.5px] text-slate-400">
            <span className="font-mono text-slate-200">{toothName}</span>
            <span className="text-slate-600">·</span>
            <span>{archLabel}</span>
          </div>
        </div>

        {/* Socket grid */}
        <div
          className="thin-scrollbar overflow-y-auto px-4 py-4 sm:px-6 sm:py-5"
          style={{ maxHeight: '50vh' }}
        >
          <div className="grid grid-cols-2 gap-1.5 sm:grid-cols-3">
            {sortedSockets.map((s) => {
              const isOccupied = occupiedSockets.has(s);
              const isSelected = pick === s;
              return (
                <button
                  key={s}
                  type="button"
                  disabled={isOccupied}
                  onClick={() => setPick(s)}
                  className={[
                    'group relative flex items-center justify-between rounded-lg border px-3 py-2 text-left transition-all duration-150',
                    isSelected
                      ? 'border-cyan-400/50 bg-cyan-500/[0.10] shadow-[0_4px_20px_-6px_rgba(34,211,238,0.6)] ring-1 ring-cyan-400/30'
                      : 'border-white/[0.08] bg-white/[0.02] hover:border-white/20 hover:bg-white/[0.05]',
                    isOccupied
                      ? 'cursor-not-allowed opacity-35'
                      : '',
                  ].join(' ')}
                >
                  <span
                    className={[
                      'font-mono text-[12px]',
                      isSelected ? 'text-cyan-200' : 'text-slate-200',
                      isOccupied ? 'line-through' : '',
                    ].join(' ')}
                  >
                    {s.replace(/^Socket_/, '')}
                  </span>
                  {isOccupied ? (
                    <span className="text-[9px] font-medium uppercase tracking-wider text-slate-500">
                      Taken
                    </span>
                  ) : isSelected ? (
                    <CheckIcon />
                  ) : (
                    <span className="h-1.5 w-1.5 rounded-full bg-slate-600 opacity-60 group-hover:opacity-100" />
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between gap-3 border-t border-white/[0.06] bg-slate-950/40 px-4 py-3 sm:px-6 sm:py-4">
          <span className="text-[11px] text-slate-500">
            <span className="font-mono tabular-nums text-slate-300">
              {occupiedSockets.size}
            </span>
            <span className="text-slate-600"> / </span>
            <span className="font-mono tabular-nums text-slate-300">
              {sortedSockets.length}
            </span>
            <span className="ml-1.5">occupied</span>
          </span>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={onCancel}
              className="rounded-lg border border-white/[0.08] bg-white/[0.02] px-4 py-2 text-[12px] font-medium text-slate-300 transition hover:border-white/15 hover:bg-white/[0.06] hover:text-white"
            >
              Cancel
            </button>
            <button
              type="button"
              disabled={!canConfirm}
              onClick={() => canConfirm && onConfirm(pick)}
              className="rounded-lg bg-gradient-to-br from-cyan-400 to-violet-500 px-4 py-2 text-[12px] font-semibold text-slate-900 shadow-[0_4px_20px_-4px_rgba(34,211,238,0.5)] transition hover:shadow-[0_6px_24px_-4px_rgba(34,211,238,0.7)] disabled:cursor-not-allowed disabled:bg-none disabled:bg-white/5 disabled:text-slate-500 disabled:shadow-none"
            >
              Place tooth
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function CheckIcon() {
  return (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="3"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="text-cyan-300"
      aria-hidden="true"
    >
      <path d="M20 6L9 17l-5-5" />
    </svg>
  );
}
