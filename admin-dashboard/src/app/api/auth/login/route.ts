import { NextResponse } from 'next/server';
import { verifyAdminCredentials, ALLOWED_ADMIN_EMAIL } from '@/lib/auth';
import { sendAdminOtp } from '@/lib/otp';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, password } = body;

    if (!email || !password) {
      return NextResponse.json(
        { error: 'Email and password are required' },
        { status: 400 }
      );
    }

    const normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail !== ALLOWED_ADMIN_EMAIL) {
      return NextResponse.json(
        { error: `Unauthorized email address. Only ${ALLOWED_ADMIN_EMAIL} is permitted.` },
        { status: 403 }
      );
    }

    const admin = await verifyAdminCredentials(normalizedEmail, password);
    if (!admin) {
      return NextResponse.json(
        { error: 'Invalid admin credentials or account inactive' },
        { status: 401 }
      );
    }

    // Credentials valid -> generate OTP and dispatch email
    const otpResult = await sendAdminOtp(admin.email);

    return NextResponse.json({
      success: true,
      requireOtp: true,
      email: admin.email,
      message: otpResult.message,
    });
  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    );
  }
}
