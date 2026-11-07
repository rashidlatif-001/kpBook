import pg8000.native

def run_migration():
    print("Connecting to Supabase PostgreSQL...")
    con = pg8000.native.Connection(
        user='postgres.tsqypxgfaajwqcgtfdkq',
        host='aws-0-eu-west-1.pooler.supabase.com',
        port=6543,
        database='postgres',
        password='Latif.00100',
        ssl_context=True
    )
    print("Connected successfully!")

    statements = [
        # 1. Profiles Table
        """
        CREATE TABLE IF NOT EXISTS public.profiles (
            id UUID PRIMARY KEY,
            full_name TEXT NOT NULL DEFAULT 'Student',
            email TEXT UNIQUE NOT NULL,
            phone_number TEXT,
            student_class TEXT DEFAULT 'Class 9',
            school TEXT DEFAULT 'Govt High School Peshawar',
            district TEXT DEFAULT 'Peshawar',
            role TEXT NOT NULL DEFAULT 'student',
            status TEXT NOT NULL DEFAULT 'active',
            created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
            last_login_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            auth_provider TEXT DEFAULT 'supabase',
            metadata JSONB DEFAULT '{}'::jsonb
        )
        """,
        # 2. Trigger function to handle new auth user signup
        """
        CREATE OR REPLACE FUNCTION public.handle_new_user()
        RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO public.profiles (id, email, full_name, role, status, created_at, last_login_at, auth_provider)
            VALUES (
                new.id,
                new.email,
                COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
                'student',
                'active',
                new.created_at,
                new.last_sign_in_at,
                'supabase'
            )
            ON CONFLICT (id) DO UPDATE SET
                email = EXCLUDED.email,
                full_name = COALESCE(new.raw_user_meta_data->>'full_name', public.profiles.full_name),
                last_login_at = COALESCE(new.last_sign_in_at, public.profiles.last_login_at);
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER
        """,
        # 3. Trigger attachment
        """
        DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users
        """,
        """
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT OR UPDATE ON auth.users
            FOR EACH ROW EXECUTE FUNCTION public.handle_new_user()
        """,
        # 4. Backfill existing users from auth.users
        """
        INSERT INTO public.profiles (id, email, full_name, role, status, created_at, last_login_at, auth_provider)
        SELECT 
            id, 
            email, 
            COALESCE(raw_user_meta_data->>'full_name', split_part(email, '@', 1)),
            'student',
            'active',
            created_at,
            last_sign_in_at,
            'supabase'
        FROM auth.users
        ON CONFLICT (id) DO NOTHING
        """,
        # 5. Login Activity Table
        """
        CREATE TABLE IF NOT EXISTS public.login_activity (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID,
            user_email TEXT NOT NULL,
            user_name TEXT,
            login_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
            ip_address TEXT,
            user_agent TEXT,
            device_info TEXT,
            status TEXT NOT NULL DEFAULT 'success'
        )
        """,
        # 6. User Activity Table
        """
        CREATE TABLE IF NOT EXISTS public.user_activity (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID,
            activity_type TEXT NOT NULL,
            description TEXT,
            details JSONB DEFAULT '{}'::jsonb,
            created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
        )
        """,
        # 7. Admin Users Table (For Web Dashboard Admin)
        """
        CREATE TABLE IF NOT EXISTS public.admin_users (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT NOT NULL DEFAULT 'Administrator',
            role TEXT NOT NULL DEFAULT 'super_admin',
            is_active BOOLEAN NOT NULL DEFAULT true,
            created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
            last_login_at TIMESTAMPTZ
        )
        """
    ]

    for i, stmt in enumerate(statements, 1):
        print(f"Executing statement {i}/{len(statements)}...")
        con.run(stmt.strip())

    print("Checking profiles table...")
    profiles = con.run("SELECT id, email, full_name, role, status, created_at FROM public.profiles;")
    print(f"Total profiles created/synced: {len(profiles)}")
    for p in profiles:
        print(f" - {p[1]} ({p[2]}) | Status: {p[4]}")

if __name__ == "__main__":
    run_migration()
