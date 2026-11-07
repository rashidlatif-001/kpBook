import React from 'react';
import Link from 'next/link';
import { Smartphone, CheckCircle2, XCircle, ArrowRight } from 'lucide-react';
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
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-bold text-slate-900 tracking-tight">Live Login Activity</h3>
          <p className="text-xs text-slate-500">Real-time authentication sessions from Flutter mobile app</p>
        </div>
        <Link
          href="/activity"
          className="text-xs font-semibold text-blue-600 hover:text-blue-800 flex items-center space-x-1"
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
                <td colSpan={5} className="py-6 text-center text-slate-400">
                  No login events recorded yet.
                </td>
              </tr>
            ) : (
              logins.map((item) => (
                <tr key={item.id} className="hover:bg-slate-50/70 transition-colors">
                  <td className="py-2.5 px-3">
                    <p className="font-semibold text-slate-900">{item.user_name || 'Student'}</p>
                    <p className="text-[11px] text-slate-400">{item.user_email}</p>
                  </td>
                  <td className="py-2.5 px-3">
                    <div className="flex items-center space-x-1.5 text-slate-600">
                      <Smartphone className="w-3.5 h-3.5 text-slate-400" />
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
  );
}

