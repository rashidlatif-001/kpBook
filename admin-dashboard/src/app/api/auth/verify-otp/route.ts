import { NextResponse } from 'next/server';
import { createSessionToken, COOKIE_NAME, ALLOWED_ADMIN_EMAIL, AdminUser } from '@/lib/auth';
import { verifyAdminOtp } from '@/lib/otp';
import { query } from '@/lib/db';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, otp } = body;

    if (!email || !otp) {
      return NextResponse.json(
        { error: 'Email and verification code are required' },
        { status: 400 }
      );
    }

    const normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail !== ALLOWED_ADMIN_EMAIL) {
      return NextResponse.json(
        { error: 'Unauthorized email address' },
        { status: 403 }
      );
    }

    const isValidOtp = await verifyAdminOtp(normalizedEmail, otp);
    if (!isValidOtp) {
      return NextResponse.json(
        { error: 'Invalid or expired verification code. Please check your inbox or click Resend.' },
        { status: 401 }
      );
    }

    // OTP is valid! Fetch administrator profile
    const users = await query<any>(
      'SELECT id, email, full_name, role, is_active FROM public.admin_users WHERE email = $1 LIMIT 1',
      [normalizedEmail]
    );

    if (!users || users.length === 0 || !users[0].is_active) {
      return NextResponse.json(
        { error: 'Administrator account not found or deactivated' },
        { status: 403 }
      );
    }

    const user = users[0];
    const admin: AdminUser = {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      is_active: user.is_active,
    };

    // Update last login timestamp
    await query('UPDATE public.admin_users SET last_login_at = now() WHERE id = $1', [admin.id]);

    // Record login activity
    try {
      await query(
        `INSERT INTO public.login_activity (user_id, user_email, user_name, device_info, status)
         VALUES ($1, $2, $3, $4, 'success')`,
        [admin.id, admin.email, admin.full_name, 'Admin Dashboard Web Client']
      );
    } catch (e) {
      console.warn('Notice: recording admin login activity:', e);
    }

    // Issue JWT session token
    const token = await createSessionToken(admin);

    const response = NextResponse.json({
      success: true,
      user: {
        id: admin.id,
        email: admin.email,
        name: admin.full_name,
        role: admin.role,
      },
    });

    response.cookies.set({
      name: COOKIE_NAME,
      value: token,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    return response;
  } catch (error: any) {
    console.error('Verify OTP error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    );
  }
}
