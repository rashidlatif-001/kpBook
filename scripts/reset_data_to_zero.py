import pg8000.native

def reset_database_to_zero():
    print("Connecting to Supabase PostgreSQL...")
    con = pg8000.native.Connection(
        user='postgres.tsqypxgfaajwqcgtfdkq',
        host='aws-0-eu-west-1.pooler.supabase.com',
        port=6543,
        database='postgres',
        password='Latif.00100',
        ssl_context=True
    )
    print("Connected!")

    # 1. Truncate user activities and logins
    con.run("TRUNCATE TABLE public.login_activity CASCADE;")
    con.run("TRUNCATE TABLE public.user_activity CASCADE;")
    print("login_activity and user_activity truncated to 0.")

    # 2. Truncate profiles
    con.run("TRUNCATE TABLE public.profiles CASCADE;")
    print("profiles truncated to 0.")

    # 3. Delete from auth.users (so new signups start from scratch)
    con.run("DELETE FROM auth.users;")
    print("auth.users cleared to 0.")

    # 4. Verify counts
    profiles_count = con.run("SELECT count(*) FROM public.profiles;")[0][0]
    logins_count = con.run("SELECT count(*) FROM public.login_activity;")[0][0]
    auth_count = con.run("SELECT count(*) FROM auth.users;")[0][0]
    admin_count = con.run("SELECT count(*) FROM public.admin_users;")[0][0]

    print("\n--- DATABASE RESET SUMMARY ---")
    print(f"Total Profiles: {profiles_count}")
    print(f"Total Logins: {logins_count}")
    print(f"Total Auth Users: {auth_count}")
    print(f"Admin Users Preserved: {admin_count}")

if __name__ == "__main__":
    reset_database_to_zero()
