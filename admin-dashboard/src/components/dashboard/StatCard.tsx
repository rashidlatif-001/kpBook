import React from 'react';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: number | string;
  subtitle?: string;
  icon: LucideIcon;
  badgeText?: string;
  badgeType?: 'success' | 'info' | 'warning' | 'neutral';
  color?: 'blue' | 'emerald' | 'indigo' | 'amber' | 'slate';
}

export function StatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  badgeText,
  badgeType = 'neutral',
  color = 'blue',
}: StatCardProps) {
  const colorMap = {
    blue: 'bg-blue-500/10 text-blue-600 border-blue-200/60',
    emerald: 'bg-emerald-500/10 text-emerald-600 border-emerald-200/60',
    indigo: 'bg-indigo-500/10 text-indigo-600 border-indigo-200/60',
    amber: 'bg-amber-500/10 text-amber-600 border-amber-200/60',
    slate: 'bg-slate-500/10 text-slate-600 border-slate-200/60',
  };

  const badgeMap = {
    success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    info: 'bg-blue-50 text-blue-700 border-blue-200',
    warning: 'bg-amber-50 text-amber-700 border-amber-200',
    neutral: 'bg-slate-100 text-slate-600 border-slate-200',
  };

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-md transition-shadow">
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{title}</span>
        <div className={`p-2.5 rounded-lg border ${colorMap[color]}`}>
          <Icon className="w-5 h-5" />
        </div>
      </div>

      <div className="flex items-baseline space-x-2">
        <h3 className="text-2xl font-extrabold text-slate-900 tracking-tight">{value}</h3>
        {badgeText && (
          <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-md border ${badgeMap[badgeType]}`}>
            {badgeText}
          </span>
        )}
      </div>

      {subtitle && <p className="text-xs text-slate-500 mt-2 font-medium">{subtitle}</p>}
    </div>
  );
}
