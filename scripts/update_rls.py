import pg8000.native

con = pg8000.native.Connection(
    user='postgres.tsqypxgfaajwqcgtfdkq',
    host='aws-0-eu-west-1.pooler.supabase.com',
    port=6543,
    database='postgres',
    password='Latif.00100',
    ssl_context=True
)

stmts = [
    "ALTER TABLE public.login_activity ENABLE ROW LEVEL SECURITY",
    "DROP POLICY IF EXISTS allow_inserts_login_activity ON public.login_activity",
    "CREATE POLICY allow_inserts_login_activity ON public.login_activity FOR INSERT TO anon, authenticated WITH CHECK (true)",
    "DROP POLICY IF EXISTS allow_select_login_activity ON public.login_activity",
    "CREATE POLICY allow_select_login_activity ON public.login_activity FOR SELECT TO authenticated, anon USING (true)"
]

for s in stmts:
    con.run(s)

print("RLS policies updated successfully!")
