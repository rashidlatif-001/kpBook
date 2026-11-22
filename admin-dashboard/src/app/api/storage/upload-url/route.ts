import { NextResponse } from 'next/server';
import { getCurrentAdmin } from '@/lib/auth';
import { isR2Configured, getR2PresignedUploadUrl } from '@/lib/r2';

export async function POST(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { filename, contentType = 'application/pdf' } = body;

    if (!filename) {
      return NextResponse.json({ error: 'Filename is required' }, { status: 400 });
    }

    if (isR2Configured) {
      const { uploadUrl, publicUrl } = await getR2PresignedUploadUrl(filename, contentType);
      return NextResponse.json({
        provider: 'r2',
        uploadUrl,
        publicUrl,
        headers: {
          'Content-Type': contentType,
        },
      });
    }

    // Fallback: Supabase Storage
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://tsqypxgfaajwqcgtfdkq.supabase.co';
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_RQ8BvygKqcRAxmndpRt_OQ_PMtfMF6x';
    const uploadUrl = `${supabaseUrl}/storage/v1/object/textbooks/${filename}`;
    const publicUrl = `${supabaseUrl}/storage/v1/object/public/textbooks/${filename}`;

    return NextResponse.json({
      provider: 'supabase',
      uploadUrl,
      publicUrl,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Content-Type': contentType,
        'x-upsert': 'true',
      },
    });
  } catch (err: any) {
    console.error('Storage upload URL error:', err);
    return NextResponse.json({ error: err.message || 'Failed to prepare upload URL' }, { status: 500 });
  }
}
