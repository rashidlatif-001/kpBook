const bcrypt = require('bcryptjs');
const { Pool } = require('pg');

async function seedAdmin() {
  const hash = await bcrypt.hash('Admin@Kpk2026!', 10);
  console.log('Generated hash:', hash);

  const pool = new Pool({
    connectionString: 'postgresql://postgres.tsqypxgfaajwqcgtfdkq:Latif.00100@aws-0-eu-west-1.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
  });

  const queryText = 'INSERT INTO public.admin_users (email, password_hash, full_name, role, is_active) ' +
    'VALUES ($1, $2, $3, $4, $5) ' +
    'ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash ' +
    'RETURNING id, email, full_name, role;';

  const res = await pool.query(queryText, [
    'admin@kpbooks.gov.pk',
    hash,
    'Directorate of Curriculum & Teacher Education (KPK)',
    'super_admin',
    true
  ]);

  console.log('Admin user successfully seeded/updated:');
  console.log(res.rows[0]);

  // Also seed some sample login activities for demonstration if empty
  const countRes = await pool.query('SELECT count(*) FROM public.login_activity;');
  if (parseInt(countRes.rows[0].count) === 0) {
    console.log('Seeding initial login activity records for existing users...');
    const usersRes = await pool.query('SELECT id, email, full_name FROM public.profiles LIMIT 5;');
    for (const u of usersRes.rows) {
      await pool.query(
        'INSERT INTO public.login_activity (user_id, user_email, user_name, login_at, ip_address, user_agent, device_info, status) ' +
        'VALUES ($1, $2, $3, now() - interval \'1 hour\', $4, $5, $6, $7);',
        [u.id, u.email, u.full_name, '103.255.4.12', 'Dart/3.9 (dart:io)', 'Android 14 (Redmi Note 12)', 'success']
      );
      await pool.query(
        'INSERT INTO public.login_activity (user_id, user_email, user_name, login_at, ip_address, user_agent, device_info, status) ' +
        'VALUES ($1, $2, $3, now() - interval \'2 days\', $4, $5, $6, $7);',
        [u.id, u.email, u.full_name, '103.255.4.12', 'Dart/3.9 (dart:io)', 'Android 14 (Redmi Note 12)', 'success']
      );
      // Activity
      await pool.query(
        'INSERT INTO public.user_activity (user_id, activity_type, description, details, created_at) ' +
        'VALUES ($1, $2, $3, $4, now() - interval \'30 minutes\');',
        [u.id, 'book_download', 'Downloaded Class 9 Physics Textbook (English Medium)', JSON.stringify({ grade: '9', subject: 'Physics', medium: 'English' })]
      );
    }
    console.log('Initial activity records seeded.');
  }

  await pool.end();
}

seedAdmin().catch(console.error);
