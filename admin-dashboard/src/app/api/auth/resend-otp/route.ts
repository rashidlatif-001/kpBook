import { NextResponse } from 'next/server';
import { ALLOWED_ADMIN_EMAIL } from '@/lib/auth';
import { sendAdminOtp } from '@/lib/otp';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email } = body;

    if (!email) {
      return NextResponse.json(
        { error: 'Email is required' },
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

    const result = await sendAdminOtp(normalizedEmail);

    return NextResponse.json({
      success: true,
      message: result.message,
      otpHint: result.otpHint,
    });
  } catch (error: any) {
    console.error('Resend OTP error:', error);
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    );
  }
}
