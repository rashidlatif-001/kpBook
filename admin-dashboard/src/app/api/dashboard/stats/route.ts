import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET() {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    // 1. Total registered users
    const totalUsersRes = await query<{ count: string }>(
      'SELECT count(*) FROM public.profiles'
    );
    const totalUsers = parseInt(totalUsersRes[0]?.count || '0', 10);

    // 2. Today's registrations
    const todayUsersRes = await query<{ count: string }>(
      'SELECT count(*) FROM public.profiles WHERE created_at >= date_trunc(\'day\', now())'
    );
    const todayUsers = parseInt(todayUsersRes[0]?.count || '0', 10);

    // 3. Weekly registrations (last 7 days)
    const weeklyUsersRes = await query<{ count: string }>(
      'SELECT count(*) FROM public.profiles WHERE created_at >= (now() - interval \'7 days\')'
    );
    const weeklyUsers = parseInt(weeklyUsersRes[0]?.count || '0', 10);

    // 4. Monthly registrations (last 30 days)
    const monthlyUsersRes = await query<{ count: string }>(
      'SELECT count(*) FROM public.profiles WHERE created_at >= (now() - interval \'30 days\')'
    );
    const monthlyUsers = parseInt(monthlyUsersRes[0]?.count || '0', 10);

    // 5. Active vs Inactive (Active = logged in within 30 days or registered within 30 days)
    const activeUsersRes = await query<{ count: string }>(
      'SELECT count(*) FROM public.profiles WHERE last_login_at >= (now() - interval \'30 days\') OR created_at >= (now() - interval \'30 days\')'
    );
    const activeUsers = parseInt(activeUsersRes[0]?.count || '0', 10);
    const inactiveUsers = Math.max(0, totalUsers - activeUsers);

    // 6. Class-wise distribution
    const classDistributionRes = await query<{ student_class: string; count: string }>(
      `SELECT COALESCE(student_class, 'Class 9') as student_class, count(*) as count 
       FROM public.profiles 
       GROUP BY student_class 
       ORDER BY student_class ASC`
    );

    // Standardize classes 1 to 12
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

    // 7. Registration trend over past 7 days
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

    // 8. Recent 5 registered users
    const recentUsers = await query<any>(
      `SELECT id, full_name, email, student_class, district, school, status, created_at, last_login_at 
       FROM public.profiles 
       ORDER BY created_at DESC 
       LIMIT 5`
    );

    // 9. Recent 6 login activity records
    const recentLogins = await query<any>(
      `SELECT id, user_id, user_email, user_name, login_at, ip_address, device_info, status 
       FROM public.login_activity 
       ORDER BY login_at DESC 
       LIMIT 6`
    );

    return NextResponse.json({
      metrics: {
        totalUsers,
        todayUsers,
        weeklyUsers,
        monthlyUsers,
        activeUsers,
        inactiveUsers,
      },
      classDistribution,
      registrationTrend,
      recentUsers,
      recentLogins,
    });
  } catch (error: any) {
    console.error('Stats query error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard statistics', details: error.message },
      { status: 500 }
    );
  }
}
