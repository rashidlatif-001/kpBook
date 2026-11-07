'use client';

import React from 'react';
import Link from 'next/link';
import { Smartphone, CheckCircle2, XCircle, ArrowRight, Shield } from 'lucide-react';
import { formatTimeAgo } from '@/lib/utils';

interface LoginItem {
  id: string;
  user_email: string;
  user_name: string;
  login_at: string;
  ip_address: string;
  device_info: string;
  status: string;
}

interface RecentActivityTableProps {
  logins: LoginItem[];
}

export function RecentActivityTable({ logins }: RecentActivityTableProps) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs flex flex-col justify-between h-full">
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-sm font-bold text-slate-900 tracking-tight">Live Login Activity</h3>
            <p className="text-xs text-slate-500">Real-time mobile authentication sessions • Click row to inspect</p>
          </div>
          <Link
            href="/activity"
            className="text-xs font-semibold text-blue-600 hover:text-blue-800 flex items-center space-x-1 hover:underline"
          >
            <span>All Logs</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50/80 text-slate-500 uppercase tracking-wider text-[10px] font-semibold border-y border-slate-200/80">
              <tr>
                <th className="py-2.5 px-3">Student</th>
                <th className="py-2.5 px-3">Device / Client</th>
                <th className="py-2.5 px-3">IP Address</th>
                <th className="py-2.5 px-3">Status</th>
                <th className="py-2.5 px-3 text-right">Time</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-700">
              {logins.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-slate-400">
                    <div className="space-y-1">
                      <p className="font-semibold text-slate-600">No login activity recorded yet</p>
                      <p className="text-[11px] text-slate-400">
                        When users open and log into the mobile app, sessions will stream here in real-time.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                logins.map((item) => (
                  <tr
                    key={item.id}
                    onClick={() => (window.location.href = '/activity')}
                    className="hover:bg-blue-50/60 transition-colors cursor-pointer group"
                    title="Click to view all activity logs"
                  >
                    <td className="py-2.5 px-3">
                      <p className="font-semibold text-slate-900 group-hover:text-blue-700 transition-colors">
                        {item.user_name || 'Student'}
                      </p>
                      <p className="text-[11px] text-slate-400">{item.user_email}</p>
                    </td>
                    <td className="py-2.5 px-3">
                      <div className="flex items-center space-x-1.5 text-slate-600">
                        <Smartphone className="w-3.5 h-3.5 text-blue-600" />
                        <span>{item.device_info || 'Android Device'}</span>
                      </div>
                    </td>
                    <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500">
                      {item.ip_address || '127.0.0.1'}
                    </td>
                    <td className="py-2.5 px-3">
                      {item.status === 'success' ? (
                        <span className="inline-flex items-center space-x-1 text-emerald-700 font-medium">
                          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
                          <span>Success</span>
                        </span>
                      ) : (
                        <span className="inline-flex items-center space-x-1 text-rose-700 font-medium">
                          <XCircle className="w-3.5 h-3.5 text-rose-500" />
                          <span>Failed</span>
                        </span>
                      )}
                    </td>
                    <td className="py-2.5 px-3 text-right text-slate-400 text-[11px]">
                      {formatTimeAgo(item.login_at)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-4 pt-3 border-t border-slate-100 text-center">
        <Link
          href="/activity"
          className="text-xs font-bold text-blue-600 hover:text-blue-800 hover:underline"
        >
          View Full Security & Activity Audit Log &rarr;
        </Link>
      </div>
    </div>
  );
}
