import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    const syncSecret = process.env.SYNC_API_SECRET || 'kpk-books-sync-secret-key-2026-auth-event-token';

    // Verify secret
    if (!authHeader || authHeader.replace('Bearer ', '') !== syncSecret) {
      return NextResponse.json({ error: 'Unauthorized sync request' }, { status: 401 });
    }

    const body = await request.json();
    const { event_type, user_id, email, full_name, student_class, district, school, device_info, ip_address } = body;

    if (!user_id || !email) {
      return NextResponse.json({ error: 'user_id and email are required' }, { status: 400 });
    }

    if (event_type === 'login' || event_type === 'signup') {
      // Upsert profile
      await query(
        `INSERT INTO public.profiles (id, email, full_name, student_class, district, school, status, last_login_at, auth_provider)
         VALUES ($1, $2, $3, COALESCE($4, 'Class 9'), COALESCE($5, 'Peshawar'), COALESCE($6, 'Govt High School'), 'active', now(), 'supabase')
         ON CONFLICT (id) DO UPDATE SET
           email = EXCLUDED.email,
           full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
           last_login_at = now();`,
        [user_id, email, full_name || splitEmail(email), student_class, district, school]
      );

      // Record login activity
      await query(
        `INSERT INTO public.login_activity (user_id, user_email, user_name, login_at, ip_address, device_info, status)
         VALUES ($1, $2, $3, now(), $4, $5, 'success')`,
        [user_id, email, full_name || splitEmail(email), ip_address || 'Mobile', device_info || 'Android App']
      );
    }

    return NextResponse.json({ success: true, message: 'Event synchronized successfully' });
  } catch (error: any) {
    console.error('Flutter event sync error:', error);
    return NextResponse.json({ error: 'Internal server error', details: error.message }, { status: 500 });
  }
}

function splitEmail(email: string): string {
  return email.split('@')[0] || 'Student';
}

