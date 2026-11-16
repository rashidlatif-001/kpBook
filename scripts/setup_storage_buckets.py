import pg8000.native

def setup_buckets():
    print("Connecting to Supabase PostgreSQL...")
    con = pg8000.native.Connection(
        user='postgres.tsqypxgfaajwqcgtfdkq',
        host='aws-0-eu-west-1.pooler.supabase.com',
        port=6543,
        database='postgres',
        password='Latif.00100',
        ssl_context=True
    )
    
    buckets = [
        ('textbooks', 'textbooks', True),
        ('textbook-assets', 'textbook-assets', True),
        ('avatars', 'avatars', True)
    ]
    
    for b_id, b_name, b_pub in buckets:
        con.run(
            "INSERT INTO storage.buckets (id, name, public) VALUES (:id, :name, :pub) ON CONFLICT (id) DO UPDATE SET public = :pub;",
            id=b_id, name=b_name, pub=b_pub
        )
        print(f"Bucket '{b_id}' ensured.")

    # Storage RLS policies to allow public read
    try:
        con.run("ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;")
        con.run("DROP POLICY IF EXISTS allow_public_read_objects ON storage.objects;")
        con.run("CREATE POLICY allow_public_read_objects ON storage.objects FOR SELECT TO anon, authenticated USING (true);")
        con.run("DROP POLICY IF EXISTS allow_all_objects ON storage.objects;")
        con.run("CREATE POLICY allow_all_objects ON storage.objects FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);")
        print("Storage RLS policies configured.")
    except Exception as e:
        print("Note configuring storage policies:", e)

    res = con.run("SELECT id, name, public FROM storage.buckets;")
    print("Active buckets:", res)
    con.close()

if __name__ == '__main__':
    setup_buckets()
