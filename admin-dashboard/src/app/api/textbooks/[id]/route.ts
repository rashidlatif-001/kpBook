import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { id } = await params;

  try {
    const books = await query<any>(
      `SELECT b.*,
        (SELECT count(*) FROM public.chapters c WHERE c.book_id = b.id) as chapters_count,
        (SELECT count(*) FROM public.topics t 
         JOIN public.chapters c ON c.id = t.chapter_id 
         WHERE c.book_id = b.id) as topics_count,
        (SELECT count(*) FROM public.content_blocks cb
         JOIN public.topics t ON t.id = cb.topic_id
         JOIN public.chapters c ON c.id = t.chapter_id
         WHERE c.book_id = b.id) as blocks_count
       FROM public.books b
       WHERE b.id = $1`,
      [id]
    );

    if (!books || books.length === 0) {
      return NextResponse.json({ error: 'Book not found' }, { status: 404 });
    }

    const chapters = await query<any>(
      `SELECT c.*,
        (SELECT count(*) FROM public.topics t WHERE t.chapter_id = c.id) as topics_count
       FROM public.chapters c
       WHERE c.book_id = $1
       ORDER BY c.chapter_number ASC`,
      [id]
    );

    return NextResponse.json({ book: books[0], chapters });
  } catch (error: any) {
    console.error('Get book error:', error);
    return NextResponse.json({ error: 'Failed to fetch book', details: error.message }, { status: 500 });
  }
}

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { id } = await params;

  try {
    const body = await request.json();
    const { publication_status, title, title_urdu, subject_name, class_number } = body;

    const updates: string[] = [];
    const values: any[] = [];

    if (publication_status !== undefined) {
      values.push(publication_status);
      updates.push(`publication_status = $${values.length}`);
    }
    if (title !== undefined) {
      values.push(title);
      updates.push(`title = $${values.length}`);
    }
    if (title_urdu !== undefined) {
      values.push(title_urdu);
      updates.push(`title_urdu = $${values.length}`);
    }
    if (subject_name !== undefined) {
      values.push(subject_name);
      updates.push(`subject_name = $${values.length}`);
    }
    if (class_number !== undefined) {
      values.push(parseInt(class_number, 10));
      updates.push(`class_number = $${values.length}`);
    }

    updates.push(`updated_at = timezone('utc'::text, now())`);

    values.push(id);
    const sql = `UPDATE public.books SET ${updates.join(', ')} WHERE id = $${values.length} RETURNING *;`;

    const updated = await query<any>(sql, values);
    return NextResponse.json({ success: true, book: updated[0] });
  } catch (error: any) {
    console.error('Update book error:', error);
    return NextResponse.json({ error: 'Failed to update book', details: error.message }, { status: 500 });
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { id } = await params;

  try {
    await query('DELETE FROM public.books WHERE id = $1', [id]);
    return NextResponse.json({ success: true, message: 'Book deleted successfully' });
  } catch (error: any) {
    console.error('Delete book error:', error);
    return NextResponse.json({ error: 'Failed to delete book', details: error.message }, { status: 500 });
  }
}
