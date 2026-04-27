import { useCallback, useEffect, useRef, useState } from 'react';

/**
 * ToothStrip
 *
 * Bottom panel with a horizontal row of tooth cards. Pagination is driven by
 * left/right arrow buttons (no visible scrollbar) — clicking either button
 * smoothly scrolls the row by one viewport width. Buttons disable when the
 * row reaches its edge.
 *
 *   - unplaced tooth → tooth appears at floating stage + modal opens
 *   - placed tooth   → selects it for fine-tuning (TransformControls)
 */
export default function ToothStrip({ teeth, selectedTooth, placements, onSelect, archLabel }) {
  const placedCount = Object.keys(placements).length;
  const scrollerRef = useRef(null);
  const [edge, setEdge] = useState({ atStart: true, atEnd: false });

  // Recompute which edge we're at — drives the disabled state of the arrows.
  // Called on scroll, on resize, and once after teeth render so the initial
  // state is correct before the user has interacted.
  const updateEdge = useCallback(() => {
    const el = scrollerRef.current;
    if (!el) return;
    const atStart = el.scrollLeft <= 1;
    const atEnd = el.scrollLeft + el.clientWidth >= el.scrollWidth - 1;
    setEdge({ atStart, atEnd });
  }, []);

  useEffect(() => {
    updateEdge();
    const el = scrollerRef.current;
    if (!el) return;
    el.addEventListener('scroll', updateEdge, { passive: true });
    window.addEventListener('resize', updateEdge);
    return () => {
      el.removeEventListener('scroll', updateEdge);
      window.removeEventListener('resize', updateEdge);
    };
  }, [updateEdge, teeth.length]);

  const scrollByPage = (dir) => {
    const el = scrollerRef.current;
    if (!el) return;
    // Step by ~85% of the visible width so the user always sees one card of
    // overlap between pages — preserves spatial context across paginations.
    const step = Math.max(160, el.clientWidth * 0.85);
    el.scrollBy({ left: dir * step, behavior: 'smooth' });
  };

  return (
    <div className="pointer-events-none absolute inset-x-0 bottom-0 z-20 px-3 pb-3 sm:px-6 sm:pb-6">
      <div className="panel-glass pointer-events-auto animate-fade-in p-3 sm:p-4">
        {/* Header */}
        <div className="mb-3 flex items-center justify-between px-1">
          <div className="flex items-center gap-2.5">
            <div className="h-1 w-6 rounded-full bg-gradient-to-r from-cyan-400 to-violet-400" />
            <span className="text-[10px] font-semibold uppercase tracking-[0.2em] text-slate-300">
              {archLabel}
            </span>
          </div>
          <span className="text-[11px] font-medium tabular-nums text-slate-400">
            <span className="text-cyan-300">{placedCount}</span>
            <span className="text-slate-500"> of </span>
            {teeth.length}
            <span className="text-slate-500"> placed</span>
          </span>
        </div>

        {/* Card row with edge-mounted nav arrows. The scroller is flanked by
            two NavArrow buttons that page it horizontally. Edge-mask gradients
            on the scroller hint that more content exists off-screen. */}
        <div className="relative">
          <NavArrow
            direction="prev"
            disabled={edge.atStart}
            onClick={() => scrollByPage(-1)}
          />

          <div
            ref={scrollerRef}
            className="no-scrollbar -mx-1 overflow-x-auto px-11 [scroll-behavior:smooth] sm:px-12"
            style={{
              maskImage:
                'linear-gradient(to right, transparent 0, black 32px, black calc(100% - 32px), transparent 100%)',
              WebkitMaskImage:
                'linear-gradient(to right, transparent 0, black 32px, black calc(100% - 32px), transparent 100%)',
            }}
          >
            <div className="flex gap-1.5 pb-1 sm:gap-2">
              {teeth.map(({ name, label }, i) => (
                <ToothCard
                  key={name}
                  index={i + 1}
                  name={name}
                  label={label}
                  socket={placements[name]}
                  isSelected={selectedTooth === name}
                  isPlaced={!!placements[name]}
                  onClick={() => onSelect(name)}
                />
              ))}
            </div>
          </div>

          <NavArrow
            direction="next"
            disabled={edge.atEnd}
            onClick={() => scrollByPage(1)}
          />
        </div>
      </div>
    </div>
  );
}

function NavArrow({ direction, disabled, onClick }) {
  // Prev sits on the left edge, next on the right. Absolute-positioned so
  // they overlay the scroller; pointer-events restored despite the parent's
  // pointer-events-none so they remain clickable.
  const isPrev = direction === 'prev';
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      aria-label={isPrev ? 'Previous teeth' : 'Next teeth'}
      className={[
        // 44px on mobile (iOS/Material touch-target threshold), 36px on desktop.
        'group absolute top-1/2 z-10 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full border border-white/[0.08] bg-slate-950/80 backdrop-blur-xl transition-all duration-150 sm:h-9 sm:w-9',
        isPrev ? 'left-0' : 'right-0',
        disabled
          ? 'cursor-not-allowed opacity-25'
          : 'hover:border-cyan-400/40 hover:bg-slate-900/90 hover:shadow-[0_4px_16px_-4px_rgba(34,211,238,0.4)] active:scale-95',
      ].join(' ')}
    >
      <ChevronIcon flipped={!isPrev} />
    </button>
  );
}

function ChevronIcon({ flipped }) {
  return (
    <svg
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.4"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      className={`text-slate-300 transition-transform group-hover:text-cyan-300 ${flipped ? 'rotate-180' : ''}`}
    >
      <path d="M15 18l-6-6 6-6" />
    </svg>
  );
}

function ToothCard({ index, name, label, socket, isSelected, isPlaced, onClick }) {
  const statusText = isPlaced
    ? socket
      ? socket.replace(/^Socket_/, '')
      : 'Placed'
    : isSelected
    ? 'Selecting'
    : 'Pending';

  const cardClasses = isSelected
    ? 'border-cyan-400/50 bg-cyan-500/[0.08] shadow-[0_8px_28px_-8px_rgba(34,211,238,0.5)] ring-1 ring-cyan-400/30'
    : isPlaced
    ? 'border-emerald-400/25 bg-emerald-400/[0.04] hover:border-emerald-400/40 hover:bg-emerald-400/[0.08]'
    : 'border-white/[0.08] bg-white/[0.02] hover:-translate-y-0.5 hover:border-white/20 hover:bg-white/[0.06] hover:shadow-[0_8px_24px_-8px_rgba(0,0,0,0.5)]';

  const statusBadgeClasses = isSelected
    ? 'bg-cyan-400/15 text-cyan-200'
    : isPlaced
    ? 'bg-emerald-400/10 text-emerald-200'
    : 'bg-white/[0.04] text-slate-400';

  return (
    <button
      type="button"
      onClick={onClick}
      className={`group relative flex min-w-[96px] shrink-0 flex-col rounded-xl border px-3 py-2 text-left transition-all duration-200 sm:min-w-[124px] sm:px-3.5 sm:py-2.5 ${cardClasses}`}
    >
      <div className="flex items-center justify-between">
        <span className="text-[10px] font-semibold uppercase tracking-wider text-slate-400">
          {label ?? `Tooth ${String(index).padStart(2, '0')}`}
        </span>
        <StatusDot isSelected={isSelected} isPlaced={isPlaced} />
      </div>

      <span
        className={`mt-2 inline-flex w-fit items-center rounded-md px-1.5 py-[2px] font-mono text-[9.5px] font-medium tracking-wide ${statusBadgeClasses}`}
      >
        {statusText}
      </span>
    </button>
  );
}

function StatusDot({ isSelected, isPlaced }) {
  if (isSelected) {
    return (
      <span className="relative flex h-2 w-2 items-center justify-center">
        <span className="absolute inline-flex h-full w-full animate-pulse-glow rounded-full bg-cyan-400" />
        <span className="h-2 w-2 rounded-full bg-cyan-400" />
      </span>
    );
  }
  if (isPlaced) {
    return (
      <span className="flex h-2 w-2 items-center justify-center">
        <span className="h-2 w-2 rounded-full bg-emerald-400 shadow-[0_0_6px_rgba(74,222,128,0.6)]" />
      </span>
    );
  }
  return <span className="h-2 w-2 rounded-full bg-slate-600" />;
}
