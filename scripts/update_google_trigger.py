import pg8000.native

def update_trigger():
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

    statement = """
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
            COALESCE(new.raw_app_meta_data->>'provider', 'supabase')
        )
        ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            full_name = COALESCE(new.raw_user_meta_data->>'full_name', public.profiles.full_name),
            last_login_at = COALESCE(new.last_sign_in_at, public.profiles.last_login_at),
            auth_provider = COALESCE(new.raw_app_meta_data->>'provider', public.profiles.auth_provider);
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
    """

    print("Updating handle_new_user trigger function...")
    con.run(statement.strip())
    print("Trigger function successfully updated to support Google and Supabase auth providers!")
    con.close()

if __name__ == "__main__":
    update_trigger()
