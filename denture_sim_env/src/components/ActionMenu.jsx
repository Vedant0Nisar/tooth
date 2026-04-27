import { useEffect, useRef, useState } from 'react';

export default function ActionMenu({
  isTransparent,
  onToggleTransparent,
  selectedTooth,
  isEditingPlaced,
  onDeselect,
  onResetPose,
  onResetTooth,
}) {
  const [open, setOpen] = useState(false);
  const [isClosing, setIsClosing] = useState(false);
  const closeTimer = useRef(null);
  const ref = useRef(null);

  const close = (itemCount = 1) => {
    setIsClosing(true);
    clearTimeout(closeTimer.current);
    // Wait for last item's close animation to finish before unmounting
    // reverse stagger: (itemCount - 1) * 80ms delay + 400ms duration
    closeTimer.current = setTimeout(() => {
      setOpen(false);
      setIsClosing(false);
    }, (itemCount - 1) * 50 + 220);
  };

  useEffect(() => {
    if (!open) return;
    const handler = (e) => {
      if (ref.current && !ref.current.contains(e.target)) close();
    };
    document.addEventListener('pointerdown', handler);
    return () => document.removeEventListener('pointerdown', handler);
  }, [open]);

  useEffect(() => () => clearTimeout(closeTimer.current), []);

  // Build the visible item list so we can assign stagger indices
  const items = [
    {
      key: 'transparent',
      label: isTransparent ? 'Transparent: On' : 'Transparent: Off',
      activeClass: 'border-cyan-400/50 bg-cyan-500/[0.12] text-cyan-300 shadow-[0_0_12px_rgba(34,211,238,0.3)]',
      inactiveClass: 'border-white/[0.08] bg-white/[0.03] text-slate-400 hover:border-white/20 hover:text-white',
      active: isTransparent,
      onClick: onToggleTransparent,
      icon: <EyeIcon active={isTransparent} />,
    },
    selectedTooth && {
      key: 'deselect',
      label: 'Deselect',
      inactiveClass: 'border-white/[0.08] bg-white/[0.03] text-slate-400 hover:border-white/20 hover:text-white',
      onClick: () => { onDeselect(); close(items.length); },
      icon: (
        <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" className="h-4 w-4">
          <line x1="4" y1="4" x2="12" y2="12" />
          <line x1="12" y1="4" x2="4" y2="12" />
        </svg>
      ),
    },
    isEditingPlaced && {
      key: 'reset',
      label: 'Reset Pose',
      inactiveClass: 'border-sky-400/20 bg-sky-500/[0.06] text-sky-400 hover:border-sky-400/40 hover:text-sky-200',
      onClick: () => { onResetPose(selectedTooth); close(items.length); },
      icon: (
        <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-4 w-4">
          <path d="M3 8a5 5 0 1 0 1.5-3.5" />
          <polyline points="3 4 3 8 7 8" />
        </svg>
      ),
    },
    isEditingPlaced && {
      key: 'free',
      label: 'Free Socket',
      inactiveClass: 'border-rose-400/20 bg-rose-500/[0.06] text-rose-400 hover:border-rose-400/40 hover:text-rose-200',
      onClick: () => { onResetTooth(selectedTooth); close(items.length); },
      icon: (
        <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="h-4 w-4">
          <rect x="5" y="7" width="7" height="6" rx="1" />
          <path d="M5 7V5a3 3 0 0 1 5.12-2.12" />
          <line x1="11" y1="2" x2="13" y2="4" />
        </svg>
      ),
    },
  ].filter(Boolean);

  return (
    <div ref={ref} className="pointer-events-auto absolute right-3 top-3 z-30 flex flex-col items-end gap-2 sm:right-6 sm:top-6">
      {/* Hamburger trigger — lines morph into ✕ when open */}
      <button
        type="button"
        onClick={() => open ? close(items.length) : setOpen(true)}
        aria-label={open ? 'Close menu' : 'Open menu'}
        className="flex h-10 w-10 items-center justify-center rounded-full border border-white/[0.10] bg-slate-900/80 text-slate-300 shadow-lg backdrop-blur-xl transition-colors hover:border-white/20 hover:text-white"
      >
        <MenuIcon open={open} />
      </button>

      {/* Dropdown — unmounts after close animation finishes */}
      {(open || isClosing) && (
        <div className="flex flex-col items-end gap-2">
          {items.map((item, i) => (
            <MenuItem
              key={item.key}
              label={item.label}
              labelDelay={i * 60}
              iconDelay={i * 60 + 40}
              labelCloseDelay={(items.length - 1 - i) * 50}
              iconCloseDelay={(items.length - 1 - i) * 50 + 25}
              isClosing={isClosing}
            >
              <CircleBtn
                onClick={item.onClick}
                active={item.active}
                activeClass={item.activeClass}
                inactiveClass={item.inactiveClass}
              >
                {item.icon}
              </CircleBtn>
            </MenuItem>
          ))}
        </div>
      )}
    </div>
  );
}

function MenuItem({ label, labelDelay, iconDelay, labelCloseDelay, iconCloseDelay, isClosing, children }) {
  return (
    <div className="flex items-center gap-2.5">
      <span
        className={`whitespace-nowrap rounded-md border border-white/[0.06] bg-slate-900/90 px-2 py-1 text-[11px] font-medium text-slate-300 shadow-sm ${isClosing ? 'menu-label-close' : 'menu-label-anim'}`}
        style={isClosing
          ? { '--close-delay': `${labelCloseDelay}ms` }
          : { '--anim-delay': `${labelDelay}ms` }}
      >
        {label}
      </span>
      <div
        className={isClosing ? 'menu-icon-close' : 'menu-icon-anim'}
        style={isClosing
          ? { '--close-delay': `${iconCloseDelay}ms` }
          : { '--anim-delay': `${iconDelay}ms` }}
      >
        {children}
      </div>
    </div>
  );
}

function CircleBtn({ onClick, active, activeClass = '', inactiveClass = '', children }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full border backdrop-blur-xl transition-all duration-150 ${active ? activeClass : inactiveClass}`}
    >
      {children}
    </button>
  );
}

// Single SVG whose three lines smoothly morph into an ✕ when `open` is true.
function MenuIcon({ open }) {
  const ease = 'transform 300ms cubic-bezier(0.16,1,0.3,1), opacity 200ms ease';
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" className="h-4 w-4 overflow-visible">
      {/* Top line → top arm of ✕ */}
      <line
        x1="2" y1="4" x2="14" y2="4"
        style={{
          transformBox: 'fill-box',
          transformOrigin: 'center',
          transform: open ? 'translateY(4px) rotate(45deg)' : 'none',
          transition: ease,
        }}
      />
      {/* Middle line → fades out */}
      <line
        x1="2" y1="8" x2="14" y2="8"
        style={{
          transformBox: 'fill-box',
          transformOrigin: 'center',
          opacity: open ? 0 : 1,
          transform: open ? 'scaleX(0)' : 'scaleX(1)',
          transition: ease,
        }}
      />
      {/* Bottom line → bottom arm of ✕ */}
      <line
        x1="2" y1="12" x2="14" y2="12"
        style={{
          transformBox: 'fill-box',
          transformOrigin: 'center',
          transform: open ? 'translateY(-4px) rotate(-45deg)' : 'none',
          transition: ease,
        }}
      />
    </svg>
  );
}

function EyeIcon({ active }) {
  return active ? (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-4 w-4">
      <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  ) : (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="h-4 w-4">
      <path d="M9.88 9.88a3 3 0 1 0 4.24 4.24" />
      <path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c6.5 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68" />
      <path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3.5 7 10 7a9.74 9.74 0 0 0 5.39-1.61" />
      <line x1="2" y1="2" x2="22" y2="22" />
    </svg>
  );
}
