import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET() {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const users = await query<any>(
      `SELECT id, full_name, email, phone_number, student_class, school, district, role, status, created_at, last_login_at 
       FROM public.profiles 
       ORDER BY created_at DESC`
    );

    const headers = [
      'User ID',
      'Full Name',
      'Email',
      'Phone Number',
      'Class',
      'School',
      'District',
      'Role',
      'Status',
      'Registration Date',
      'Last Login Date',
    ];

    const escapeCsv = (val: any) => {
      if (val === null || val === undefined) return '""';
      const str = String(val).replace(/"/g, '""');
      return `"${str}"`;
    };

    const csvRows = [
      headers.join(','),
      ...users.map(u =>
        [
          escapeCsv(u.id),
          escapeCsv(u.full_name),
          escapeCsv(u.email),
          escapeCsv(u.phone_number || 'N/A'),
          escapeCsv(u.student_class || 'Class 9'),
          escapeCsv(u.school || 'Govt High School'),
          escapeCsv(u.district || 'Peshawar'),
          escapeCsv(u.role || 'student'),
          escapeCsv(u.status || 'active'),
          escapeCsv(u.created_at ? new Date(u.created_at).toISOString() : 'N/A'),
          escapeCsv(u.last_login_at ? new Date(u.last_login_at).toISOString() : 'Never'),
        ].join(',')
      ),
    ];

    const csvContent = csvRows.join('\n');
    const fileName = `kpk_books_registered_users_${new Date().toISOString().split('T')[0]}.csv`;

    return new NextResponse(csvContent, {
      status: 200,
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="${fileName}"`,
      },
    });
  } catch (error: any) {
    console.error('CSV Export error:', error);
    return NextResponse.json(
      { error: 'Failed to export CSV', details: error.message },
      { status: 500 }
    );
  }
}

