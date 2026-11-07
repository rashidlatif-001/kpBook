import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const { searchParams } = new URL(request.url);
    const page = Math.max(1, parseInt(searchParams.get('page') || '1', 10));
    const limit = Math.max(1, Math.min(100, parseInt(searchParams.get('limit') || '20', 10)));
    const offset = (page - 1) * limit;

    const countRes = await query<{ count: string }>('SELECT count(*) FROM public.login_activity');
    const totalCount = parseInt(countRes[0]?.count || '0', 10);

    const logins = await query<any>(
      `SELECT id, user_id, user_email, user_name, login_at, ip_address, user_agent, device_info, status 
       FROM public.login_activity 
       ORDER BY login_at DESC 
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    // Also get recent student activities
    const userActivities = await query<any>(
      `SELECT ua.id, ua.user_id, ua.activity_type, ua.description, ua.details, ua.created_at, p.full_name, p.email
       FROM public.user_activity ua
       LEFT JOIN public.profiles p ON ua.user_id = p.id
       ORDER BY ua.created_at DESC
       LIMIT 10`
    );

    return NextResponse.json({
      logins,
      userActivities,
      pagination: {
        total: totalCount,
        page,
        limit,
        totalPages: Math.ceil(totalCount / limit) || 1,
      },
    });
  } catch (error: any) {
    console.error('Activity fetch error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch activity records', details: error.message },
      { status: 500 }
    );
  }
}
