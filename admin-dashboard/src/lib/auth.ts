import { SignJWT, jwtVerify } from 'jose';
import bcrypt from 'bcryptjs';
import { cookies } from 'next/headers';
import { query } from './db';

const JWT_SECRET = new TextEncoder().encode(
  process.env.JWT_SECRET || 'kpk-books-secret-jwt-key-2026-super-secure-token-998877'
);
export const COOKIE_NAME = process.env.ADMIN_SESSION_COOKIE || 'kpk_admin_session';

export interface AdminUser {
  id: string;
  email: string;
  full_name: string;
  role: 'super_admin' | 'editor' | 'viewer';
  is_active: boolean;
}

export async function createSessionToken(user: AdminUser): Promise<string> {
  return await new SignJWT({
    id: user.id,
    email: user.email,
    name: user.full_name,
    role: user.role,
  })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .sign(JWT_SECRET);
}

export async function verifySessionToken(token: string): Promise<AdminUser | null> {
  try {
    const { payload } = await jwtVerify(token, JWT_SECRET);
    return {
      id: payload.id as string,
      email: payload.email as string,
      full_name: payload.name as string,
      role: (payload.role as AdminUser['role']) || 'super_admin',
      is_active: true,
    };
  } catch {
    return null;
  }
}

export async function getCurrentAdmin(): Promise<AdminUser | null> {
  try {
    const cookieStore = await cookies();
    const token = cookieStore.get(COOKIE_NAME)?.value;
    if (!token) return null;
    return await verifySessionToken(token);
  } catch {
    return null;
  }
}

export async function verifyAdminCredentials(
  email: string,
  plainPassword: string
): Promise<AdminUser | null> {
  const users = await query<any>(
    'SELECT id, email, password_hash, full_name, role, is_active FROM public.admin_users WHERE email = $1 LIMIT 1',
    [email.trim().toLowerCase()]
  );

  if (!users || users.length === 0) return null;
  const user = users[0];
  if (!user.is_active) return null;

  const isValid = await bcrypt.compare(plainPassword, user.password_hash);
  if (!isValid) return null;

  // Update last login
  await query('UPDATE public.admin_users SET last_login_at = now() WHERE id = $1', [user.id]);

  return {
    id: user.id,
    email: user.email,
    full_name: user.full_name,
    role: user.role,
    is_active: user.is_active,
  };
}
