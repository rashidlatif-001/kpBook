'use client';

import React from 'react';
import { GraduationCap } from 'lucide-react';

interface ClassItem {
  class_name: string;
  users: number;
}

interface ClassDistributionChartProps {
  data: ClassItem[];
}

export function ClassDistributionChart({ data }: ClassDistributionChartProps) {
  const totalStudents = data.reduce((acc, curr) => acc + curr.users, 0);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-bold text-slate-900 tracking-tight">Class-wise Distribution</h3>
          <p className="text-xs text-slate-500">Student enrollment across grades 1–12</p>
        </div>
        <div className="flex items-center space-x-1 px-2.5 py-1 rounded-lg bg-emerald-50 border border-emerald-200/60 text-emerald-700 text-xs font-semibold">
          <GraduationCap className="w-3.5 h-3.5" />
          <span>{totalStudents} Total</span>
        </div>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5 pt-2">
        {data.map((item, idx) => {
          const percentage = totalStudents > 0 ? Math.round((item.users / totalStudents) * 100) : 0;
          return (
            <div
              key={idx}
              className={`p-3 rounded-lg border transition-all ${
                item.users > 0
                  ? 'bg-blue-50/50 border-blue-200/70 shadow-2xs'
                  : 'bg-slate-50/70 border-slate-200/60'
              }`}
            >
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-xs font-bold text-slate-800">{item.class_name}</span>
                <span className={`text-[11px] font-extrabold ${item.users > 0 ? 'text-blue-700' : 'text-slate-400'}`}>
                  {item.users}
                </span>
              </div>
              <div className="w-full bg-slate-200/80 rounded-full h-1.5 overflow-hidden">
                <div
                  className="bg-blue-600 h-1.5 rounded-full transition-all duration-500"
                  style={{ width: `${item.users > 0 ? Math.max(12, percentage) : 0}%` }}
                />
              </div>
              <div className="flex justify-between items-center mt-1.5 text-[10px] text-slate-500">
                <span>{percentage}% share</span>
                <span className={item.users > 0 ? 'text-emerald-600 font-medium' : 'text-slate-400'}>
                  {item.users > 0 ? 'Active' : 'Empty'}
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
