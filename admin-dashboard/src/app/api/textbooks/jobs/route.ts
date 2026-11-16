import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET() {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const jobs = await query<any>(
      `SELECT j.*, b.title as book_title, b.subject_name, b.class_number, b.file_size
       FROM public.extraction_jobs j
       JOIN public.books b ON b.id = j.book_id
       ORDER BY j.created_at DESC
       LIMIT 50;`
    );

    return NextResponse.json({ jobs });
  } catch (error: any) {
    console.error('Fetch extraction jobs error:', error);
    return NextResponse.json({ error: 'Failed to fetch jobs', details: error.message }, { status: 500 });
  }
}
