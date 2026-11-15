'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Clock } from 'lucide-react';

interface InactivityWatcherProps {
  timeoutSeconds?: number;
}

export function InactivityWatcher({ timeoutSeconds = 30 }: InactivityWatcherProps) {
  const router = useRouter();
  const lastActivityRef = useRef<number>(Date.now());
  const [secondsRemaining, setSecondsRemaining] = useState<number>(timeoutSeconds);
  const [showWarning, setShowWarning] = useState<boolean>(false);

  useEffect(() => {
    // Reset activity timer whenever user moves mouse, types, clicks, or scrolls
    const resetTimer = () => {
      lastActivityRef.current = Date.now();
      setShowWarning(false);
      setSecondsRemaining(timeoutSeconds);
    };

    const events = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart', 'click'];
    events.forEach((evt) => {
      window.addEventListener(evt, resetTimer, { passive: true });
    });

    // Check idle duration every 1 second
    const interval = setInterval(async () => {
      const elapsed = Math.floor((Date.now() - lastActivityRef.current) / 1000);
      const remaining = Math.max(0, timeoutSeconds - elapsed);
      setSecondsRemaining(remaining);

      // Display subtle warning in the last 10 seconds of inactivity
      if (remaining <= 10 && remaining > 0) {
        setShowWarning(true);
      } else {
        setShowWarning(false);
      }

      // 30 seconds of inactivity reached -> trigger automatic logout!
      if (remaining === 0) {
        clearInterval(interval);
        try {
          await fetch('/api/auth/logout', { method: 'POST' });
        } catch {
          // Continue with redirect
        }
        router.push('/login?reason=inactivity');
        router.refresh();
      }
    }, 1000);

    return () => {
      clearInterval(interval);
      events.forEach((evt) => {
        window.removeEventListener(evt, resetTimer);
      });
    };
  }, [router, timeoutSeconds]);

  if (!showWarning) return null;

  return (
    <div className="fixed bottom-6 right-6 z-50 pointer-events-none animate-fadeIn">
      <div className="bg-rose-950/95 border border-rose-500/60 text-white px-4 py-3 rounded-2xl shadow-2xl flex items-center space-x-3 backdrop-blur-md">
        <div className="w-8 h-8 rounded-xl bg-rose-500/20 flex items-center justify-center text-rose-400">
          <Clock className="w-4 h-4 animate-spin" />
        </div>
        <div>
          <p className="text-xs font-bold text-rose-200">Security Inactivity Warning</p>
          <p className="text-[11px] text-rose-300">
            Auto-logout in <span className="font-mono font-extrabold text-white">{secondsRemaining}s</span> due to no activity.
          </p>
        </div>
      </div>
    </div>
  );
}
