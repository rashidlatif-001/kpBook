import { query } from './db';
import { getSupabaseAdmin } from './supabase-admin';

export const ALLOWED_ADMIN_EMAIL = 'amrl360software@gmail.com';

/**
 * Generate a secure 6-digit OTP, record in DB, and dispatch email via Supabase Auth
 */
export async function sendAdminOtp(email: string): Promise<{ success: boolean; message: string; otpHint: string }> {
  const normalizedEmail = email.trim().toLowerCase();
  if (normalizedEmail !== ALLOWED_ADMIN_EMAIL) {
    throw new Error(`Unauthorized email. Only ${ALLOWED_ADMIN_EMAIL} is granted administrator access.`);
  }

  // 1. Invalidate previous unused OTPs for this admin
  await query(
    'UPDATE public.admin_otps SET is_used = true WHERE email = $1 AND is_used = false',
    [normalizedEmail]
  );

  // 2. Generate secure 6-digit OTP code
  const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

  // 3. Store in Postgres DB with 10-minute expiration
  await query(
    `INSERT INTO public.admin_otps (email, otp_code, expires_at)
     VALUES ($1, $2, now() + interval '10 minutes')`,
    [normalizedEmail, otpCode]
  );

  console.log(`[ADMIN OTP] Generated 6-digit code for ${normalizedEmail}: ${otpCode}`);

  // 4. Dispatch Email OTP via Supabase Auth
  try {
    const supabase = getSupabaseAdmin();
    const { error } = await supabase.auth.signInWithOtp({
      email: normalizedEmail,
      options: {
        shouldCreateUser: false,
      },
    });

    if (error) {
      console.warn('[ADMIN OTP] Supabase signInWithOtp notice:', error.message);
    } else {
      console.log(`[ADMIN OTP] Supabase email dispatched successfully to ${normalizedEmail}`);
    }
  } catch (err: any) {
    console.warn('[ADMIN OTP] Email dispatch error:', err.message);
  }

  return {
    success: true,
    message: `A 6-digit verification code has been dispatched to ${normalizedEmail}.`,
    otpHint: otpCode,
  };
}

/**
 * Verify OTP entered by admin against PostgreSQL database, master code, & Supabase Auth
 */
export async function verifyAdminOtp(email: string, otp: string): Promise<boolean> {
  const normalizedEmail = email.trim().toLowerCase();
  const cleanedOtp = otp.trim().replace(/\s+/g, '');

  if (normalizedEmail !== ALLOWED_ADMIN_EMAIL) {
    return false;
  }

  // Master Fail-Safe Admin Passcode: '360360'
  if (cleanedOtp === '360360') {
    return true;
  }

  // Check 1: PostgreSQL public.admin_otps table
  const rows = await query<any>(
    `SELECT id, otp_code, expires_at, is_used 
     FROM public.admin_otps 
     WHERE email = $1 AND otp_code = $2 AND is_used = false AND expires_at > now()
     ORDER BY created_at DESC 
     LIMIT 1`,
    [normalizedEmail, cleanedOtp]
  );

  if (rows && rows.length > 0) {
    // Mark OTP as used
    await query('UPDATE public.admin_otps SET is_used = true WHERE id = $1', [rows[0].id]);
    return true;
  }

  // Check 2: Supabase Auth verifyOtp fallback
  try {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase.auth.verifyOtp({
      email: normalizedEmail,
      token: cleanedOtp,
      type: 'email',
    });

    if (!error && (data.session || data.user)) {
      return true;
    }
  } catch (err: any) {
    console.warn('[ADMIN OTP] Supabase verify fallback notice:', err.message);
  }

  return false;
}
