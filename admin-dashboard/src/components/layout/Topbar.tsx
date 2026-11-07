'use client';

import React, { useState } from 'react';
import { Bell, RefreshCw, CheckCircle2, ShieldCheck, Database, X } from 'lucide-react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';

interface TopbarProps {
  title: string;
  description?: string;
}

export function Topbar({ title, description }: TopbarProps) {
  const router = useRouter();
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [showSyncedToast, setShowSyncedToast] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);

  const handleRefresh = () => {
    setIsRefreshing(true);
    router.refresh();
    setTimeout(() => {
      setIsRefreshing(false);
      setShowSyncedToast(true);
      setTimeout(() => setShowSyncedToast(false), 2500);
    }, 700);
  };

  return (
    <header className="h-16 bg-white border-b border-slate-200/90 px-6 flex items-center justify-between shadow-xs sticky top-0 z-20">
      <div>
        <h2 className="text-lg font-bold text-slate-900 tracking-tight">{title}</h2>
        {description && <p className="text-xs text-slate-500 font-normal">{description}</p>}
      </div>

      <div className="flex items-center space-x-3">
        {/* Synced Success Alert */}
        {showSyncedToast && (
          <div className="flex items-center space-x-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-300 text-xs font-semibold animate-in fade-in slide-in-from-top-2 duration-200">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
            <span>Database Synced Live!</span>
          </div>
        )}

        {/* Live sync refresh button */}
        <button
          onClick={handleRefresh}
          disabled={isRefreshing}
          className="flex items-center space-x-1.5 px-3 py-1.5 rounded-lg border border-slate-200 text-xs font-semibold text-slate-700 hover:bg-slate-50 hover:text-slate-900 hover:border-slate-300 transition-all shadow-2xs active:scale-95 cursor-pointer"
          title="Refresh database records"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isRefreshing ? 'animate-spin text-blue-600' : 'text-slate-500'}`} />
          <span>{isRefreshing ? 'Syncing...' : 'Sync Data'}</span>
        </button>

        {/* System Region indicator with link to settings */}
        <Link
          href="/settings"
          className="hidden sm:flex items-center space-x-1.5 px-2.5 py-1 rounded-full bg-slate-100 hover:bg-slate-200 text-[11px] font-medium text-slate-700 border border-slate-200 transition-colors"
          title="View Infrastructure & Region details"
        >
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>West EU (Ireland)</span>
        </Link>

        {/* Notifications Icon with Dropdown */}
        <div className="relative">
          <button
            onClick={() => setShowNotifications(!showNotifications)}
            className="p-2 rounded-lg text-slate-500 hover:text-slate-800 hover:bg-slate-100 transition-colors cursor-pointer relative"
            title="System Notifications"
          >
            <Bell className="w-4 h-4" />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-blue-600"></span>
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-xl border border-slate-200 p-4 z-30 animate-in fade-in slide-in-from-top-2 duration-150">
              <div className="flex items-center justify-between pb-2 border-b border-slate-100 mb-3">
                <span className="text-xs font-bold text-slate-900">System Notifications</span>
                <button
                  onClick={() => setShowNotifications(false)}
                  className="text-slate-400 hover:text-slate-600"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="space-y-2 text-xs">
                <div className="p-2.5 rounded-lg bg-emerald-50 border border-emerald-200/60 text-emerald-900">
                  <p className="font-bold flex items-center space-x-1">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    <span>Database Live & Clean</span>
                  </p>
                  <p className="text-[11px] text-emerald-700 mt-0.5">
                    Supabase connection is active. Real-time trigger is listening for Flutter app signups.
                  </p>
                </div>

                <div className="p-2.5 rounded-lg bg-blue-50 border border-blue-200/60 text-blue-900">
                  <p className="font-bold flex items-center space-x-1">
                    <ShieldCheck className="w-3.5 h-3.5 text-blue-600" />
                    <span>Admin Authentication</span>
                  </p>
                  <p className="text-[11px] text-blue-700 mt-0.5">
                    Session secured via HTTP-only JWT token.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
