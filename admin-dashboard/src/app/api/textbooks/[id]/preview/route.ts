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
    const bookRows = await query<any>(
      'SELECT * FROM public.books WHERE id = $1',
      [id]
    );
    if (!bookRows || bookRows.length === 0) {
      return NextResponse.json({ error: 'Book not found' }, { status: 404 });
    }

    const chapters = await query<any>(
      'SELECT * FROM public.chapters WHERE book_id = $1 ORDER BY chapter_number ASC',
      [id]
    );

    const fullChapters = [];

    for (const ch of chapters) {
      const topics = await query<any>(
        'SELECT * FROM public.topics WHERE chapter_id = $1 ORDER BY display_order ASC',
        [ch.id]
      );

      const fullTopics = [];
      for (const t of topics) {
        const blocks = await query<any>(
          'SELECT * FROM public.content_blocks WHERE topic_id = $1 ORDER BY display_order ASC',
          [t.id]
        );
        fullTopics.push({
          ...t,
          content_blocks: blocks,
        });
      }

      fullChapters.push({
        ...ch,
        topics: fullTopics,
      });
    }

    return NextResponse.json({
      book: bookRows[0],
      chapters: fullChapters,
    });
  } catch (error: any) {
    console.error('Fetch preview error:', error);
    return NextResponse.json({ error: 'Failed to fetch textbook preview', details: error.message }, { status: 500 });
  }
}

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { block_id, content, block_type, original_pdf_page } = body;

    if (!block_id || !content) {
      return NextResponse.json({ error: 'block_id and content are required' }, { status: 400 });
    }

    const updated = await query<any>(
      `UPDATE public.content_blocks
       SET content = $1,
           block_type = COALESCE($2, block_type),
           original_pdf_page = COALESCE($3, original_pdf_page)
       WHERE id = $4
       RETURNING *;`,
      [content, block_type, original_pdf_page ? parseInt(original_pdf_page, 10) : null, block_id]
    );

    return NextResponse.json({ success: true, block: updated[0] });
  } catch (error: any) {
    console.error('Update content block error:', error);
    return NextResponse.json({ error: 'Failed to update content block', details: error.message }, { status: 500 });
  }
}
