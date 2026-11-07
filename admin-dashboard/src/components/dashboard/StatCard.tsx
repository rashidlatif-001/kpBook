import React from 'react';
import Link from 'next/link';
import { LucideIcon, ArrowUpRight } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: number | string;
  subtitle?: string;
  icon: LucideIcon;
  badgeText?: string;
  badgeType?: 'success' | 'info' | 'warning' | 'neutral';
  color?: 'blue' | 'emerald' | 'indigo' | 'amber' | 'slate';
  href?: string;
  onClick?: () => void;
}

export function StatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  badgeText,
  badgeType = 'neutral',
  color = 'blue',
  href,
  onClick,
}: StatCardProps) {
  const colorMap = {
    blue: 'bg-blue-500/10 text-blue-600 border-blue-200/60 group-hover:bg-blue-600 group-hover:text-white',
    emerald: 'bg-emerald-500/10 text-emerald-600 border-emerald-200/60 group-hover:bg-emerald-600 group-hover:text-white',
    indigo: 'bg-indigo-500/10 text-indigo-600 border-indigo-200/60 group-hover:bg-indigo-600 group-hover:text-white',
    amber: 'bg-amber-500/10 text-amber-600 border-amber-200/60 group-hover:bg-amber-600 group-hover:text-white',
    slate: 'bg-slate-500/10 text-slate-600 border-slate-200/60 group-hover:bg-slate-700 group-hover:text-white',
  };

  const badgeMap = {
    success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
    info: 'bg-blue-50 text-blue-700 border-blue-200',
    warning: 'bg-amber-50 text-amber-700 border-amber-200',
    neutral: 'bg-slate-100 text-slate-600 border-slate-200',
  };

  const cardContent = (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs hover:shadow-lg hover:border-blue-400 hover:-translate-y-1 transition-all duration-200 group relative overflow-hidden h-full flex flex-col justify-between">
      {/* Top row */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider group-hover:text-blue-700 transition-colors">
            {title}
          </span>
          <div className="flex items-center space-x-1.5">
            <div className={`p-2.5 rounded-lg border transition-all duration-200 ${colorMap[color]}`}>
              <Icon className="w-5 h-5" />
            </div>
            {href && (
              <div className="opacity-0 group-hover:opacity-100 transition-opacity p-1 text-blue-600 bg-blue-50 rounded-md">
                <ArrowUpRight className="w-4 h-4" />
              </div>
            )}
          </div>
        </div>

        {/* Metric and badge */}
        <div className="flex items-baseline space-x-2">
          <h3 className="text-3xl font-black text-slate-900 tracking-tight group-hover:text-blue-600 transition-colors">
            {value}
          </h3>
          {badgeText && (
            <span className={`text-[11px] font-semibold px-2 py-0.5 rounded-md border ${badgeMap[badgeType]}`}>
              {badgeText}
            </span>
          )}
        </div>
      </div>

      {/* Subtitle / Footer */}
      <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
        <span className="font-medium truncate">{subtitle || 'Click to view records'}</span>
        {href && (
          <span className="text-[11px] font-bold text-blue-600 opacity-80 group-hover:opacity-100 group-hover:translate-x-0.5 transition-all">
            View &rarr;
          </span>
        )}
      </div>
    </div>
  );

  if (href) {
    return (
      <Link href={href} className="block cursor-pointer">
        {cardContent}
      </Link>
    );
  }

  if (onClick) {
    return (
      <button onClick={onClick} className="block w-full text-left cursor-pointer">
        {cardContent}
      </button>
    );
  }

  return cardContent;
}
