import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';

export async function GET() {
  try {
    const announcements = await query<any>(
      `SELECT id, title, message, related_class, type, action_label, created_at
       FROM public.app_updates
       ORDER BY created_at DESC`
    );
    return NextResponse.json({ announcements });
  } catch (error: any) {
    console.error('Failed to fetch announcements:', error);
    return NextResponse.json(
      { error: 'Failed to fetch announcements', details: error.message },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized. Please login as an administrator.' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { title, message, action_label, related_class, type } = body;

    if (!title || typeof title !== 'string' || !title.trim()) {
      return NextResponse.json({ error: 'Announcement title is required.' }, { status: 400 });
    }

    if (!message || typeof message !== 'string' || !message.trim()) {
      return NextResponse.json({ error: 'Announcement description / message is required.' }, { status: 400 });
    }

    const classNum = related_class && related_class !== 'all' ? parseInt(related_class, 10) : null;
    const badgeLabel = action_label && action_label.trim().length > 0 ? action_label.trim() : 'Curriculum 2024–25';
    const noticeType = type && type.trim().length > 0 ? type.trim() : 'notice';

    const result = await query<any>(
      `INSERT INTO public.app_updates (id, title, message, related_class, type, action_label, created_at)
       VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, NOW())
       RETURNING *`,
      [title.trim(), message.trim(), classNum, noticeType, badgeLabel]
    );

    return NextResponse.json({
      success: true,
      message: 'Announcement published successfully to mobile app!',
      announcement: result[0],
    });
  } catch (error: any) {
    console.error('Failed to create announcement:', error);
    return NextResponse.json(
      { error: 'Failed to broadcast announcement', details: error.message },
      { status: 500 }
    );
  }
}

export async function DELETE(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  }

  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json({ error: 'Announcement ID is required.' }, { status: 400 });
    }

    await query('DELETE FROM public.app_updates WHERE id = $1', [id]);
    return NextResponse.json({ success: true, message: 'Announcement deleted.' });
  } catch (error: any) {
    console.error('Failed to delete announcement:', error);
    return NextResponse.json(
      { error: 'Failed to delete announcement', details: error.message },
      { status: 500 }
    );
  }
}
