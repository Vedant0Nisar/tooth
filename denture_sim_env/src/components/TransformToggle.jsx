/**
 * TransformToggle
 *
 * Modern segmented control. Two pills with a sliding gradient background
 * indicating the active mode. Visible only while a placed tooth is selected.
 */
export default function TransformToggle({ mode, onChange }) {
  return (
    <div className="pointer-events-auto absolute left-1/2 top-16 z-30 -translate-x-1/2 sm:top-6">
      <div className="panel-pill relative inline-flex items-center p-1">
        {/* Sliding indicator */}
        <span
          aria-hidden="true"
          className="pointer-events-none absolute inset-y-1 w-[calc(50%-4px)] rounded-full bg-gradient-to-br from-cyan-400 to-violet-500 shadow-[0_4px_16px_rgba(34,211,238,0.45)] transition-[transform] duration-300 ease-[cubic-bezier(0.16,1,0.3,1)]"
          style={{
            transform: `translateX(${mode === 'translate' ? '0%' : 'calc(100% + 4px)'})`,
          }}
        />

        <ToggleButton
          active={mode === 'translate'}
          onClick={() => onChange('translate')}
          label="Move"
          shortcut="W"
          icon={<MoveIcon />}
        />
        <ToggleButton
          active={mode === 'rotate'}
          onClick={() => onChange('rotate')}
          label="Rotate"
          shortcut="E"
          icon={<RotateIcon />}
        />
      </div>
    </div>
  );
}

function ToggleButton({ active, onClick, label, shortcut, icon }) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={label}
      className={[
        'relative z-10 flex items-center gap-1.5 rounded-full px-3 py-2.5 text-[12px] font-medium transition-colors sm:gap-2 sm:px-5 sm:py-1.5',
        active ? 'text-slate-900' : 'text-slate-300 hover:text-white',
      ].join(' ')}
    >
      <span className="opacity-90">{icon}</span>
      <span className="tracking-tight">{label}</span>
      <kbd
        className={[
          'hidden rounded px-1 py-px font-mono text-[9px] tracking-wide transition-colors sm:inline',
          active ? 'bg-slate-900/20 text-slate-900' : 'bg-white/5 text-slate-500',
        ].join(' ')}
      >
        {shortcut}
      </kbd>
    </button>
  );
}

function MoveIcon() {
  return (
    <svg
      width="15"
      height="15"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M5 9l-3 3 3 3M9 5l3-3 3 3M15 19l-3 3-3-3M19 9l3 3-3 3M2 12h20M12 2v20" />
    </svg>
  );
}

function RotateIcon() {
  return (
    <svg
      width="15"
      height="15"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M21 12a9 9 0 1 1-3.5-7.1" />
      <path d="M21 4v5h-5" />
    </svg>
  );
}
