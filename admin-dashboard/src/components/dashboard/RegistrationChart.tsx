'use client';

import React from 'react';
import Link from 'next/link';
import { Calendar, ArrowUpRight } from 'lucide-react';

interface TrendItem {
  date: string;
  count: number;
}

interface RegistrationChartProps {
  data: TrendItem[];
}

export function RegistrationChart({ data }: RegistrationChartProps) {
  const maxCount = Math.max(...data.map(d => d.count), 5);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs flex flex-col justify-between">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-bold text-slate-900 tracking-tight">Student Registration Trend</h3>
          <p className="text-xs text-slate-500">Daily signups over the last 7 days</p>
        </div>
        <Link
          href="/users"
          className="flex items-center space-x-1.5 px-2.5 py-1 rounded-lg bg-blue-50 border border-blue-200/60 text-blue-700 text-xs font-semibold hover:bg-blue-100 transition-colors"
        >
          <Calendar className="w-3.5 h-3.5" />
          <span>Last 7 Days</span>
          <ArrowUpRight className="w-3 h-3 ml-0.5" />
        </Link>
      </div>

      {/* Bar Chart Container */}
      <div className="h-56 flex items-end justify-between gap-3 pt-6 pb-2 px-2 border-b border-slate-100">
        {data.map((item, idx) => {
          const heightPercent = Math.max(8, Math.round((item.count / maxCount) * 100));
          return (
            <Link
              key={idx}
              href="/users"
              className="flex-1 flex flex-col items-center group relative h-full justify-end cursor-pointer"
              title={`View students for ${item.date}`}
            >
              {/* Tooltip on hover */}
              <div className="absolute -top-8 opacity-0 group-hover:opacity-100 transition-opacity bg-slate-900 text-white text-[11px] font-semibold py-1 px-2 rounded pointer-events-none z-10 whitespace-nowrap shadow-md">
                {item.count} {item.count === 1 ? 'student' : 'students'} (Click to view)
              </div>

              {/* Bar */}
              <div
                style={{ height: `${heightPercent}%` }}
                className={`w-full max-w-[36px] rounded-t-md transition-all duration-300 group-hover:scale-y-105 ${
                  item.count > 0
                    ? 'bg-gradient-to-t from-blue-700 to-blue-500 group-hover:from-blue-800 group-hover:to-blue-600 shadow-sm'
                    : 'bg-slate-100 group-hover:bg-slate-200'
                }`}
              />

              {/* Count label */}
              <span className={`text-[11px] font-bold mt-2 ${item.count > 0 ? 'text-blue-700 font-extrabold' : 'text-slate-700'}`}>
                {item.count}
              </span>

              {/* Date label */}
              <span className="text-[10px] text-slate-400 mt-0.5 truncate w-full text-center group-hover:text-blue-600 font-medium">
                {item.date}
              </span>
            </Link>
          );
        })}
      </div>

      <div className="mt-3 flex items-center justify-between text-xs text-slate-400 font-medium">
        <span>Click any date bar to view registrations</span>
        <Link href="/users" className="text-blue-600 font-semibold hover:underline">
          View All Students &rarr;
        </Link>
      </div>
    </div>
  );
}
