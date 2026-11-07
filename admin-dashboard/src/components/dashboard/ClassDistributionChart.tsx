'use client';

import React from 'react';
import Link from 'next/link';
import { GraduationCap, ArrowUpRight } from 'lucide-react';

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
          <p className="text-xs text-slate-500">Click any class below to filter students instantly</p>
        </div>
        <Link
          href="/users"
          className="flex items-center space-x-1 px-2.5 py-1 rounded-lg bg-emerald-50 border border-emerald-200/60 text-emerald-700 text-xs font-semibold hover:bg-emerald-100 transition-colors"
        >
          <GraduationCap className="w-3.5 h-3.5" />
          <span>{totalStudents} Total</span>
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5 pt-2">
        {data.map((item, idx) => {
          const percentage = totalStudents > 0 ? Math.round((item.users / totalStudents) * 100) : 0;
          return (
            <Link
              key={idx}
              href={`/users?class=${encodeURIComponent(item.class_name)}`}
              className={`p-3 rounded-lg border transition-all duration-200 cursor-pointer group hover:shadow-md hover:-translate-y-0.5 ${
                item.users > 0
                  ? 'bg-blue-50/60 border-blue-300 hover:border-blue-500 hover:bg-blue-50'
                  : 'bg-slate-50/70 border-slate-200/70 hover:border-blue-300 hover:bg-white'
              }`}
              title={`View all ${item.class_name} students`}
            >
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-xs font-bold text-slate-800 group-hover:text-blue-700 transition-colors flex items-center space-x-1">
                  <span>{item.class_name}</span>
                  <ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity text-blue-600" />
                </span>
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
                <span className={`font-medium ${item.users > 0 ? 'text-emerald-700 font-bold' : 'text-slate-400'}`}>
                  {item.users > 0 ? 'View list' : '0 registered'}
                </span>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
