import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const classFilter = searchParams.get('class');
  const statusFilter = searchParams.get('status');
  const search = searchParams.get('search') || '';

  try {
    let sql = `
      SELECT b.*, 
        (SELECT count(*) FROM public.chapters c WHERE c.book_id = b.id) as chapters_count,
        (SELECT count(*) FROM public.topics t 
         JOIN public.chapters c ON c.id = t.chapter_id 
         WHERE c.book_id = b.id) as topics_count
      FROM public.books b
      WHERE 1=1
    `;
    const params: any[] = [];

    if (classFilter && classFilter !== 'all') {
      params.push(parseInt(classFilter, 10));
      sql += ` AND b.class_number = $${params.length}`;
    }

    if (statusFilter && statusFilter !== 'all') {
      params.push(statusFilter);
      sql += ` AND b.publication_status = $${params.length}`;
    }

    if (search.trim()) {
      params.push(`%${search.trim().toLowerCase()}%`);
      sql += ` AND (LOWER(b.title) LIKE $${params.length} OR LOWER(b.subject_name) LIKE $${params.length})`;
    }

    sql += ' ORDER BY b.class_number ASC, b.created_at DESC';

    const books = await query(sql, params);
    return NextResponse.json({ books });
  } catch (error: any) {
    console.error('Fetch books error:', error);
    return NextResponse.json({ error: 'Failed to fetch textbooks', details: error.message }, { status: 500 });
  }
}

export async function POST(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const {
      title,
      title_urdu,
      class_number,
      subject_name,
      board_name,
      publisher,
      edition,
      group_type,
      book_type,
      file_hash,
      total_pages,
      file_size,
    } = body;

    if (!title || !class_number || !subject_name) {
      return NextResponse.json({ error: 'Title, Class Number, and Subject are required' }, { status: 400 });
    }

    // Insert Book record
    const bookRows = await query<any>(
      `INSERT INTO public.books (
        title, title_urdu, class_number, subject_name, board_name,
        publisher, edition, group_type, book_type, file_hash,
        total_pages, file_size, extraction_status, publication_status
      ) VALUES (
        $1, $2, $3, $4, COALESCE($5, 'Khyber Pakhtunkhwa Textbook Board, Peshawar'),
        COALESCE($6, 'KPK Textbook Board'), COALESCE($7, '2024–25'),
        COALESCE($8, 'Science'), COALESCE($9, 'book'), $10,
        COALESCE($11, 0), COALESCE($12, '0 MB'), 'pending', 'draft'
      ) RETURNING id;`,
      [
        title, title_urdu || '', parseInt(class_number, 10), subject_name,
        board_name, publisher, edition, group_type, book_type, file_hash,
        total_pages ? parseInt(total_pages, 10) : 0, file_size || '0 MB'
      ]
    );

    const bookId = bookRows[0].id;

    // Create Extraction Job
    const jobRows = await query<any>(
      `INSERT INTO public.extraction_jobs (
        book_id, status, total_pages, current_stage, started_at
      ) VALUES ($1, 'queued', $2, 'uploading', now())
      RETURNING id;`,
      [bookId, total_pages ? parseInt(total_pages, 10) : 0]
    );

    return NextResponse.json({
      success: true,
      book_id: bookId,
      job_id: jobRows[0].id,
      message: 'Textbook registered and extraction job queued.'
    });
  } catch (error: any) {
    console.error('Create textbook error:', error);
    return NextResponse.json({ error: 'Failed to create textbook', details: error.message }, { status: 500 });
  }
}
