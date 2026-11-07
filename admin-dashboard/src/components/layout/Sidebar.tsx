'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  LayoutDashboard,
  Users,
  Activity,
  BarChart3,
  Settings,
  LogOut,
  BookOpen,
  ShieldCheck,
  ChevronRight,
} from 'lucide-react';

interface SidebarProps {
  adminName?: string;
  adminEmail?: string;
  adminRole?: string;
}

export function Sidebar({ adminName = 'KPK Admin', adminEmail = 'admin@kpbooks.gov.pk', adminRole = 'Super Admin' }: SidebarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [loggingOut, setLoggingOut] = React.useState(false);

  const navigation = [
    { name: 'Dashboard Overview', href: '/', icon: LayoutDashboard },
    { name: 'User Management', href: '/users', icon: Users },
    { name: 'Login Activity', href: '/activity', icon: Activity },
    { name: 'Analytics & Insights', href: '/analytics', icon: BarChart3 },
    { name: 'System Settings', href: '/settings', icon: Settings },
  ];

  const handleLogout = async () => {
    setLoggingOut(true);
    try {
      await fetch('/api/auth/logout', { method: 'POST' });
      router.push('/login');
      router.refresh();
    } catch (err) {
      console.error(err);
      setLoggingOut(false);
    }
  };

  return (
    <aside className="w-64 bg-slate-900 text-slate-200 min-h-screen flex flex-col border-r border-slate-800 shadow-xl shrink-0">
      {/* Brand Header */}
      <div className="p-5 border-b border-slate-800/80 bg-slate-950/40">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-700 to-indigo-500 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
            <BookOpen className="w-5 h-5" />
          </div>
          <div>
            <h1 className="font-bold text-white text-base leading-tight tracking-wide">KPK Books</h1>
            <p className="text-xs text-blue-400 font-medium">Admin Portal</p>
          </div>
        </div>
        <div className="mt-3 px-2 py-1 rounded bg-slate-800/70 text-[11px] font-mono text-emerald-400 flex items-center space-x-1.5 border border-slate-700/50">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>Supabase DB Connected</span>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto">
        <p className="px-3 text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-2">
          Management
        </p>
        {navigation.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center justify-between px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all ${
                isActive
                  ? 'bg-blue-600 text-white shadow-md shadow-blue-600/30'
                  : 'text-slate-300 hover:bg-slate-800/80 hover:text-white'
              }`}
            >
              <div className="flex items-center space-x-3">
                <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                <span>{item.name}</span>
              </div>
              {isActive && <ChevronRight className="w-3.5 h-3.5 text-blue-200" />}
            </Link>
          );
        })}
      </nav>

      {/* Admin Profile & Logout Footer */}
      <div className="p-4 border-t border-slate-800/80 bg-slate-950/60">
        <div className="flex items-center space-x-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-blue-900/80 border border-blue-500/30 flex items-center justify-center text-blue-300 font-bold text-sm">
            {adminName.charAt(0)}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-semibold text-white truncate">{adminName}</p>
            <p className="text-[11px] text-slate-400 truncate">{adminEmail}</p>
          </div>
          <span title={adminRole}>
            <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0" />
          </span>
        </div>

        <button
          onClick={handleLogout}
          disabled={loggingOut}
          className="w-full flex items-center justify-center space-x-2 px-3 py-2 rounded-lg bg-slate-800/90 hover:bg-rose-900/30 hover:text-rose-300 hover:border-rose-700/50 text-slate-300 border border-slate-700/60 text-xs font-medium transition-colors"
        >
          <LogOut className="w-3.5 h-3.5" />
          <span>{loggingOut ? 'Logging out...' : 'Sign Out'}</span>
        </button>
      </div>
    </aside>
  );
}
