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
    const search = searchParams.get('search') || '';
    const studentClass = searchParams.get('class') || '';
    const district = searchParams.get('district') || '';
    const status = searchParams.get('status') || '';
    const sortBy = searchParams.get('sort_by') || 'created_at';
    const order = searchParams.get('order')?.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const page = Math.max(1, parseInt(searchParams.get('page') || '1', 10));
    const limit = Math.max(1, Math.min(100, parseInt(searchParams.get('limit') || '10', 10)));
    const offset = (page - 1) * limit;

    const whereClauses: string[] = ['1=1'];
    const params: any[] = [];

    if (search.trim()) {
      params.push(`%${search.trim().toLowerCase()}%`);
      const pIdx = params.length;
      whereClauses.push(
        `(LOWER(full_name) LIKE $${pIdx} OR LOWER(email) LIKE $${pIdx} OR LOWER(COALESCE(district, '')) LIKE $${pIdx} OR LOWER(COALESCE(school, '')) LIKE $${pIdx} OR LOWER(COALESCE(phone_number, '')) LIKE $${pIdx})`
      );
    }

    if (studentClass.trim()) {
      params.push(studentClass.trim());
      whereClauses.push(`student_class = $${params.length}`);
    }

    if (district.trim()) {
      params.push(district.trim());
      whereClauses.push(`district = $${params.length}`);
    }

    if (status.trim()) {
      params.push(status.trim());
      whereClauses.push(`status = $${params.length}`);
    }

    const timeframe = searchParams.get('timeframe') || '';
    if (timeframe === 'today') {
      whereClauses.push(`created_at >= date_trunc('day', now())`);
    } else if (timeframe === 'weekly') {
      whereClauses.push(`created_at >= (now() - interval '7 days')`);
    } else if (timeframe === 'monthly') {
      whereClauses.push(`created_at >= (now() - interval '30 days')`);
    }

    const whereSql = whereClauses.join(' AND ');

    // Allowed sort columns
    const allowedSortColumns: Record<string, string> = {
      created_at: 'created_at',
      full_name: 'full_name',
      email: 'email',
      student_class: 'student_class',
      last_login_at: 'last_login_at',
      district: 'district',
      status: 'status',
    };
    const sortCol = allowedSortColumns[sortBy] || 'created_at';

    // Total matching users
    const countQuery = `SELECT count(*) FROM public.profiles WHERE ${whereSql}`;
    const countRes = await query<{ count: string }>(countQuery, params);
    const totalCount = parseInt(countRes[0]?.count || '0', 10);

    // Users list query
    params.push(limit);
    const limitIdx = params.length;
    params.push(offset);
    const offsetIdx = params.length;

    const listQuery = `
      SELECT id, full_name, email, phone_number, student_class, school, district, role, status, created_at, last_login_at, auth_provider
      FROM public.profiles
      WHERE ${whereSql}
      ORDER BY ${sortCol} ${order}
      LIMIT $${limitIdx} OFFSET $${offsetIdx}
    `;

    const users = await query<any>(listQuery, params);

    return NextResponse.json({
      users,
      pagination: {
        total: totalCount,
        page,
        limit,
        totalPages: Math.ceil(totalCount / limit) || 1,
      },
    });
  } catch (error: any) {
    console.error('Fetch users error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users', details: error.message },
      { status: 500 }
    );
  }
}

