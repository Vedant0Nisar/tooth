/**
 * TransparencyToggle
 *
 * Pill button at top-right that flips the gum + teeth between fully opaque
 * and 45% opacity (x-ray-like). Useful for inspecting tooth roots and
 * placement alignment through the gum.
 */
export default function TransparencyToggle({ active, onToggle }) {
  return (
    <div className="pointer-events-auto absolute right-3 top-3 z-30 animate-fade-in sm:right-6 sm:top-6">
      <button
        type="button"
        onClick={onToggle}
        aria-pressed={active}
        aria-label={active ? 'Disable transparent view' : 'Enable transparent view'}
        title={active ? 'Disable transparent view' : 'Enable transparent view'}
        className={[
          'panel-pill flex items-center gap-2 px-3 py-2 text-[12px] font-medium transition-all duration-200 sm:gap-2.5 sm:px-4',
          active
            ? 'text-cyan-200 ring-1 ring-cyan-400/40 shadow-[0_4px_20px_-4px_rgba(34,211,238,0.45)]'
            : 'text-slate-300 hover:text-white',
        ].join(' ')}
      >
        <EyeIcon active={active} />
        {/* Label hidden on mobile — the icon + ON/OFF chip already convey
            state, and we need to leave horizontal room for the HUD chip. */}
        <span className="hidden tracking-tight sm:inline">Transparent view</span>
        <span
          className={[
            'rounded px-1.5 py-[2px] font-mono text-[9.5px] font-semibold tracking-wide',
            active ? 'bg-cyan-400/15 text-cyan-200' : 'bg-white/[0.06] text-slate-500',
          ].join(' ')}
        >
          {active ? 'ON' : 'OFF'}
        </span>
      </button>
    </div>
  );
}

function EyeIcon({ active }) {
  // Open-eye when transparency is active (you "see through"), eye-with-slash
  // when off — matches the typical visibility-toggle vocabulary.
  return active ? (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  ) : (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M9.88 9.88a3 3 0 1 0 4.24 4.24" />
      <path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c6.5 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68" />
      <path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3.5 7 10 7a9.74 9.74 0 0 0 5.39-1.61" />
      <line x1="2" y1="2" x2="22" y2="22" />
    </svg>
  );
}
