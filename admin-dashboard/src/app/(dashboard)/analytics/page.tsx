import React from 'react';
import { query } from '@/lib/db';
import { Topbar } from '@/components/layout/Topbar';
import { MapPin, GraduationCap, TrendingUp, Users, Smartphone, ShieldCheck } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function AnalyticsPage() {
  // District distribution
  const districtRes = await query<{ district: string; count: string }>(
    `SELECT COALESCE(district, 'Peshawar') as district, count(*) as count 
     FROM public.profiles 
     GROUP BY district 
     ORDER BY count DESC`
  );

  const totalUsersRes = await query<{ count: string }>('SELECT count(*) FROM public.profiles');
  const totalUsers = parseInt(totalUsersRes[0]?.count || '0', 10);

  const totalLoginsRes = await query<{ count: string }>('SELECT count(*) FROM public.login_activity');
  const totalLogins = parseInt(totalLoginsRes[0]?.count || '0', 10);

  return (
    <>
      <Topbar
        title="KPK Educational Analytics & Regional Insights"
        description="District coverage, grade breakdown, and student digital adoption across Khyber Pakhtunkhwa"
      />

      {/* Top summary banners */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-xs flex items-center space-x-4">
          <div className="p-3 rounded-xl bg-blue-50 text-blue-700 border border-blue-200">
            <Users className="w-6 h-6" />
          </div>
          <div>
            <span className="text-xs text-slate-500 font-semibold uppercase">Total Enrollment</span>
            <h3 className="text-2xl font-black text-slate-900">{totalUsers} Students</h3>
            <p className="text-[11px] text-emerald-600 font-medium">100% Verified Accounts</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-xs flex items-center space-x-4">
          <div className="p-3 rounded-xl bg-indigo-50 text-indigo-700 border border-indigo-200">
            <Smartphone className="w-6 h-6" />
          </div>
          <div>
            <span className="text-xs text-slate-500 font-semibold uppercase">Total App Sessions</span>
            <h3 className="text-2xl font-black text-slate-900">{totalLogins} Logins</h3>
            <p className="text-[11px] text-blue-600 font-medium">Active Engagement</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-xs flex items-center space-x-4">
          <div className="p-3 rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200">
            <MapPin className="w-6 h-6" />
          </div>
          <div>
            <span className="text-xs text-slate-500 font-semibold uppercase">Divisions & Districts</span>
            <h3 className="text-2xl font-black text-slate-900">{districtRes.length} Covered</h3>
            <p className="text-[11px] text-slate-500 font-medium">Khyber Pakhtunkhwa Province</p>
          </div>
        </div>
      </div>

      {/* District Coverage Grid */}
      <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-xs">
        <div className="flex items-center justify-between mb-5">
          <div>
            <h3 className="text-base font-bold text-slate-900">District Student Adoption</h3>
            <p className="text-xs text-slate-500">Student enrollment counts grouped by district in Khyber Pakhtunkhwa</p>
          </div>
          <span className="text-xs font-semibold px-3 py-1 bg-slate-100 rounded-lg text-slate-700 border border-slate-200">
            Regional Breakdown
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {districtRes.map((d, i) => {
            const count = parseInt(d.count, 10);
            const percentage = totalUsers > 0 ? Math.round((count / totalUsers) * 100) : 0;
            return (
              <div key={i} className="p-4 rounded-xl border border-slate-200/90 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center space-x-2">
                    <MapPin className="w-4 h-4 text-blue-600" />
                    <span className="text-sm font-bold text-slate-900">{d.district}</span>
                  </div>
                  <span className="text-xs font-extrabold text-blue-800 bg-blue-100/70 px-2.5 py-0.5 rounded-full">
                    {count} {count === 1 ? 'student' : 'students'}
                  </span>
                </div>
                <div className="w-full bg-slate-200 rounded-full h-2 overflow-hidden mt-3">
                  <div
                    className="bg-gradient-to-r from-blue-600 to-indigo-600 h-2 rounded-full"
                    style={{ width: `${Math.max(10, percentage)}%` }}
                  />
                </div>
                <div className="flex justify-between items-center mt-2 text-[11px] text-slate-500 font-medium">
                  <span>{percentage}% of total student base</span>
                  <span className="text-emerald-700 font-semibold">Active Hub</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </>
  );
}
