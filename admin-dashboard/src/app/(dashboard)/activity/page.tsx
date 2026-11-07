import React from 'react';
import { query } from '@/lib/db';
import { Topbar } from '@/components/layout/Topbar';
import { Smartphone, CheckCircle2, XCircle, BookDown, Search, BookmarkCheck, Calendar, Clock } from 'lucide-react';
import { formatDate, formatTimeAgo } from '@/lib/utils';

export const dynamic = 'force-dynamic';

export default async function ActivityPage() {
  const logins = await query<any>(
    `SELECT id, user_id, user_email, user_name, login_at, ip_address, user_agent, device_info, status 
     FROM public.login_activity 
     ORDER BY login_at DESC 
     LIMIT 50`
  );

  const activities = await query<any>(
    `SELECT ua.id, ua.user_id, ua.activity_type, ua.description, ua.details, ua.created_at, p.full_name, p.email, p.student_class
     FROM public.user_activity ua
     LEFT JOIN public.profiles p ON ua.user_id = p.id
     ORDER BY ua.created_at DESC
     LIMIT 30`
  );

  return (
    <>
      <Topbar
        title="Student Activity & Audit Logs"
        description="Comprehensive audit trail of Flutter mobile authentication sessions and textbook engagement"
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Logins Stream */}
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
            <div className="p-4 border-b border-slate-200 flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold text-slate-900">Authentication Sessions</h3>
                <p className="text-xs text-slate-500">Live logins via Email/Password & OTP tokens</p>
              </div>
              <span className="text-xs font-semibold px-2.5 py-1 rounded-md bg-blue-50 text-blue-700 border border-blue-200">
                {logins.length} Total Sessions
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 text-slate-600 uppercase text-[10px] font-bold border-b border-slate-200">
                  <tr>
                    <th className="py-2.5 px-4">Student</th>
                    <th className="py-2.5 px-4">Device</th>
                    <th className="py-2.5 px-4">IP Address</th>
                    <th className="py-2.5 px-4">Status</th>
                    <th className="py-2.5 px-4 text-right">Timestamp</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-slate-700">
                  {logins.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="py-8 text-center text-slate-400">
                        No authentication sessions recorded.
                      </td>
                    </tr>
                  ) : (
                    logins.map((item) => (
                      <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                        <td className="py-3 px-4">
                          <p className="font-bold text-slate-900">{item.user_name || 'Student'}</p>
                          <p className="text-[11px] text-slate-400">{item.user_email}</p>
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex items-center space-x-1.5 text-slate-600 font-medium">
                            <Smartphone className="w-3.5 h-3.5 text-blue-600" />
                            <span>{item.device_info || 'Android App'}</span>
                          </div>
                        </td>
                        <td className="py-3 px-4 font-mono text-[11px] text-slate-500">
                          {item.ip_address || '127.0.0.1'}
                        </td>
                        <td className="py-3 px-4">
                          {item.status === 'success' ? (
                            <span className="inline-flex items-center space-x-1 text-emerald-700 font-semibold">
                              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
                              <span>Success</span>
                            </span>
                          ) : (
                            <span className="inline-flex items-center space-x-1 text-rose-700 font-semibold">
                              <XCircle className="w-3.5 h-3.5 text-rose-500" />
                              <span>Failed</span>
                            </span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-right text-slate-500 text-[11px]">
                          {formatDate(item.login_at)}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Student Content Engagement Stream */}
        <div className="lg:col-span-1 space-y-4">
          <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs">
            <h3 className="text-sm font-bold text-slate-900 mb-1">Textbook Engagements</h3>
            <p className="text-xs text-slate-500 mb-4">Book downloads, reads, and searches</p>

            <div className="space-y-3.5">
              {activities.length === 0 ? (
                <p className="text-xs text-slate-400 py-6 text-center">No engagements recorded yet.</p>
              ) : (
                activities.map((act) => (
                  <div key={act.id} className="p-3 rounded-lg border border-slate-100 bg-slate-50/60 space-y-1.5">
                    <div className="flex items-center justify-between text-[11px]">
                      <span className="font-bold text-blue-800 flex items-center space-x-1">
                        <BookDown className="w-3.5 h-3.5 text-blue-600" />
                        <span>{act.activity_type.replace('_', ' ').toUpperCase()}</span>
                      </span>
                      <span className="text-slate-400">{formatTimeAgo(act.created_at)}</span>
                    </div>
                    <p className="text-xs font-semibold text-slate-800">{act.description}</p>
                    <p className="text-[11px] text-slate-500">
                      by <span className="font-semibold text-slate-700">{act.full_name || act.email}</span> ({act.student_class || 'Class 9'})
                    </p>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
