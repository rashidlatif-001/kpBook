import React from 'react';
import { query } from '@/lib/db';
import { Topbar } from '@/components/layout/Topbar';
import { StatCard } from '@/components/dashboard/StatCard';
import { RegistrationChart } from '@/components/dashboard/RegistrationChart';
import { ClassDistributionChart } from '@/components/dashboard/ClassDistributionChart';
import { RecentUsersList } from '@/components/dashboard/RecentUsersList';
import { RecentActivityTable } from '@/components/dashboard/RecentActivityTable';
import { Users, UserCheck, Calendar, Activity, GraduationCap, ShieldCheck } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function DashboardPage() {
  // 1. Metrics from real Supabase DB
  const totalUsersRes = await query<{ count: string }>('SELECT count(*) FROM public.profiles');
  const totalUsers = parseInt(totalUsersRes[0]?.count || '0', 10);

  const todayUsersRes = await query<{ count: string }>(
    'SELECT count(*) FROM public.profiles WHERE created_at >= date_trunc(\'day\', now())'
  );
  const todayUsers = parseInt(todayUsersRes[0]?.count || '0', 10);

  const weeklyUsersRes = await query<{ count: string }>(
    'SELECT count(*) FROM public.profiles WHERE created_at >= (now() - interval \'7 days\')'
  );
  const weeklyUsers = parseInt(weeklyUsersRes[0]?.count || '0', 10);

  const monthlyUsersRes = await query<{ count: string }>(
    'SELECT count(*) FROM public.profiles WHERE created_at >= (now() - interval \'30 days\')'
  );
  const monthlyUsers = parseInt(monthlyUsersRes[0]?.count || '0', 10);

  const activeUsersRes = await query<{ count: string }>(
    'SELECT count(*) FROM public.profiles WHERE last_login_at >= (now() - interval \'30 days\') OR created_at >= (now() - interval \'30 days\')'
  );
  const activeUsers = parseInt(activeUsersRes[0]?.count || '0', 10);
  const inactiveUsers = Math.max(0, totalUsers - activeUsers);

  // 2. Class Distribution
  const classDistributionRes = await query<{ student_class: string; count: string }>(
    `SELECT COALESCE(student_class, 'Class 9') as student_class, count(*) as count 
     FROM public.profiles 
     GROUP BY student_class 
     ORDER BY student_class ASC`
  );

  const allClasses = [
    'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
    'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10',
    'Class 11', 'Class 12'
  ];
  const classMap: Record<string, number> = {};
  allClasses.forEach(c => classMap[c] = 0);
  classDistributionRes.forEach(r => {
    const className = r.student_class || 'Class 9';
    classMap[className] = (classMap[className] || 0) + parseInt(r.count, 10);
  });
  const classDistribution = Object.keys(classMap).map(c => ({
    class_name: c,
    users: classMap[c],
  }));

  // 3. 7-Day Trend
  const trendRes = await query<{ day_date: string; count: string }>(
    `SELECT to_char(d, 'Mon DD') as day_date, count(p.id) as count
     FROM generate_series(date_trunc('day', now() - interval '6 days'), date_trunc('day', now()), interval '1 day') d
     LEFT JOIN public.profiles p ON date_trunc('day', p.created_at) = d
     GROUP BY d
     ORDER BY d ASC`
  );
  const registrationTrend = trendRes.map(t => ({
    date: t.day_date,
    count: parseInt(t.count, 10),
  }));

  // 4. Recent Users
  const recentUsers = await query<any>(
    `SELECT id, full_name, email, student_class, district, school, status, created_at, last_login_at 
     FROM public.profiles 
     ORDER BY created_at DESC 
     LIMIT 5`
  );

  // 5. Recent Logins
  const recentLogins = await query<any>(
    `SELECT id, user_id, user_email, user_name, login_at, ip_address, device_info, status 
     FROM public.login_activity 
     ORDER BY login_at DESC 
     LIMIT 6`
  );

  return (
    <>
      <Topbar
        title="Education Administration Overview"
        description="Live monitoring of KPK E-Textbooks students, sessions, and downloads"
      />

      {/* Top Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Total Registered Students"
          value={totalUsers}
          subtitle="All-time verified mobile accounts"
          icon={Users}
          color="blue"
          badgeText="Live DB"
          badgeType="info"
        />

        <StatCard
          title="Today's Signups"
          value={todayUsers}
          subtitle="New registrations in last 24h"
          icon={Calendar}
          color="emerald"
          badgeText={todayUsers > 0 ? `+${todayUsers} Today` : 'No new yet'}
          badgeType="success"
        />

        <StatCard
          title="Active Students"
          value={activeUsers}
          subtitle={`${inactiveUsers} currently inactive`}
          icon={UserCheck}
          color="indigo"
          badgeText="Active 30d"
          badgeType="info"
        />

        <StatCard
          title="Weekly Growth"
          value={weeklyUsers}
          subtitle={`${monthlyUsers} signups in last 30 days`}
          icon={Activity}
          color="amber"
          badgeText="Last 7 Days"
          badgeType="warning"
        />
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RegistrationChart data={registrationTrend} />
        <ClassDistributionChart data={classDistribution} />
      </div>

      {/* Tables Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <RecentUsersList users={recentUsers} />
        </div>
        <div className="lg:col-span-2">
          <RecentActivityTable logins={recentLogins} />
        </div>
      </div>
    </>
  );
}
