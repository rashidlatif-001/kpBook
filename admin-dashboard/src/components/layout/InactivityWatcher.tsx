'use client';

import { useEffect, useRef, useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { Clock, ShieldAlert } from 'lucide-react';

interface InactivityWatcherProps {
  /** Inactivity timeout in seconds. Default is 300s (5 minutes). */
  timeoutSeconds?: number;
}

export function InactivityWatcher({ timeoutSeconds = 300 }: InactivityWatcherProps) {
  const router = useRouter();
  const lastActivityRef = useRef<number>(Date.now());
  const showWarningRef = useRef<boolean>(false);
  const [secondsRemaining, setSecondsRemaining] = useState<number>(timeoutSeconds);
  const [showWarning, setShowWarning] = useState<boolean>(false);

  // Instant activity reset callback (keeps session alive on any cursor movement, keypress, click)
  const handleUserActivity = useCallback(() => {
    lastActivityRef.current = Date.now();
    if (showWarningRef.current) {
      showWarningRef.current = false;
      setShowWarning(false);
      setSecondsRemaining(timeoutSeconds);
    }
  }, [timeoutSeconds]);

  useEffect(() => {
    lastActivityRef.current = Date.now();

    // Comprehensive list of user engagement events
    const interactionEvents = [
      'mousemove',
      'pointermove',
      'mousedown',
      'mouseup',
      'keydown',
      'scroll',
      'wheel',
      'touchstart',
      'touchmove',
      'click',
      'focus',
    ];

    // Throttle listener to optimize performance while continuously tracking cursor
    let lastHandled = 0;
    const throttledListener = () => {
      const now = Date.now();
      lastActivityRef.current = now;
      if (now - lastHandled > 400) {
        lastHandled = now;
        if (showWarningRef.current) {
          showWarningRef.current = false;
          setShowWarning(false);
          setSecondsRemaining(timeoutSeconds);
        }
      }
    };

    interactionEvents.forEach((evt) => {
      window.addEventListener(evt, throttledListener, { passive: true, capture: true });
      document.addEventListener(evt, throttledListener, { passive: true, capture: true });
    });

    // Check idle status every second
    const interval = setInterval(async () => {
      const idleSeconds = Math.floor((Date.now() - lastActivityRef.current) / 1000);
      const remaining = Math.max(0, timeoutSeconds - idleSeconds);
      setSecondsRemaining(remaining);

      // Show security alert in the last 30 seconds of 5-minute inactivity
      if (remaining <= 30 && remaining > 0) {
        if (!showWarningRef.current) {
          showWarningRef.current = true;
          setShowWarning(true);
        }
      } else if (remaining > 30) {
        if (showWarningRef.current) {
          showWarningRef.current = false;
          setShowWarning(false);
        }
      }

      // If full 5 minutes of no screen activity reached -> log out automatically
      if (remaining === 0) {
        clearInterval(interval);
        try {
          await fetch('/api/auth/logout', { method: 'POST' });
        } catch {
          // Continue redirect
        }
        router.push('/login?reason=inactivity');
        router.refresh();
      }
    }, 1000);

    return () => {
      clearInterval(interval);
      interactionEvents.forEach((evt) => {
        window.removeEventListener(evt, throttledListener, { capture: true });
        document.removeEventListener(evt, throttledListener, { capture: true });
      });
    };
  }, [router, timeoutSeconds]);

  if (!showWarning) return null;

  return (
    <div className="fixed bottom-6 right-6 z-50 animate-fadeIn pointer-events-auto">
      <div className="bg-slate-900/95 border-2 border-amber-500/80 text-white px-5 py-4 rounded-2xl shadow-2xl flex items-center space-x-4 backdrop-blur-xl ring-4 ring-amber-500/20 max-w-sm">
        <div className="w-10 h-10 rounded-xl bg-amber-500/20 flex items-center justify-center text-amber-400 shrink-0">
          <Clock className="w-5 h-5 animate-pulse" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-xs font-bold text-amber-300 flex items-center gap-1.5">
            <ShieldAlert className="w-3.5 h-3.5" />
            Inactivity Warning
          </p>
          <p className="text-[11px] text-slate-300 mt-0.5 leading-snug">
            Logging out in <span className="font-mono font-black text-amber-400 text-xs">{secondsRemaining}s</span> due to no activity.
          </p>
          <p className="text-[10px] text-slate-400 mt-1">
            Move your cursor or click anywhere to stay logged in.
          </p>
        </div>
        <button
          onClick={handleUserActivity}
          className="px-3 py-1.5 bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-xs rounded-lg transition-colors cursor-pointer shrink-0 shadow-sm"
        >
          I&apos;m here
        </button>
      </div>
    </div>
  );
}
