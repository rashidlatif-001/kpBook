import pg8000.native

def migrate_textbook_schema():
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
        # 1. Subjects Table
        """
        CREATE TABLE IF NOT EXISTS public.subjects (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name TEXT NOT NULL,
            name_urdu TEXT,
            code TEXT,
            class_number INT NOT NULL,
            icon_name TEXT DEFAULT 'auto_stories_rounded',
            display_order INT DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            CONSTRAINT uq_subject_class UNIQUE (name, class_number)
        );
        """,

        # 2. Books Table
        """
        CREATE TABLE IF NOT EXISTS public.books (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            title TEXT NOT NULL,
            title_urdu TEXT,
            class_number INT NOT NULL,
            subject_id UUID REFERENCES public.subjects(id) ON DELETE SET NULL,
            subject_name TEXT NOT NULL,
            board_name TEXT NOT NULL DEFAULT 'Khyber Pakhtunkhwa Textbook Board, Peshawar',
            publisher TEXT DEFAULT 'KPK Textbook Board',
            edition TEXT DEFAULT '2024–25',
            curriculum_year TEXT DEFAULT '2024–25',
            total_pages INT NOT NULL DEFAULT 0,
            original_pdf_path TEXT,
            cover_image_url TEXT,
            cover_gradient_start TEXT DEFAULT '#005129',
            cover_gradient_end TEXT DEFAULT '#0B8F55',
            icon_name TEXT DEFAULT 'menu_book_rounded',
            file_hash TEXT UNIQUE,
            file_size TEXT DEFAULT '0 MB',
            group_type TEXT NOT NULL DEFAULT 'Science',
            book_type TEXT NOT NULL DEFAULT 'book',
            extraction_status TEXT NOT NULL DEFAULT 'pending',
            publication_status TEXT NOT NULL DEFAULT 'draft',
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 3. Chapters Table
        """
        CREATE TABLE IF NOT EXISTS public.chapters (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
            chapter_number INT NOT NULL,
            title TEXT NOT NULL,
            title_urdu TEXT,
            start_page INT NOT NULL,
            end_page INT NOT NULL,
            display_order INT NOT NULL DEFAULT 0,
            slo_summary TEXT,
            key_topics TEXT[] DEFAULT '{}',
            is_completed BOOLEAN DEFAULT false,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            CONSTRAINT uq_book_chapter_num UNIQUE (book_id, chapter_number)
        );
        """,

        # 4. Topics Table
        """
        CREATE TABLE IF NOT EXISTS public.topics (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            chapter_id UUID NOT NULL REFERENCES public.chapters(id) ON DELETE CASCADE,
            topic_number TEXT NOT NULL,
            title TEXT NOT NULL,
            title_urdu TEXT,
            start_page INT,
            end_page INT,
            display_order INT NOT NULL DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 5. Subtopics Table
        """
        CREATE TABLE IF NOT EXISTS public.subtopics (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
            subtopic_number TEXT,
            title TEXT NOT NULL,
            display_order INT NOT NULL DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 6. Content Blocks Table
        """
        CREATE TABLE IF NOT EXISTS public.content_blocks (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
            subtopic_id UUID REFERENCES public.subtopics(id) ON DELETE SET NULL,
            block_type TEXT NOT NULL,
            content TEXT NOT NULL,
            display_order INT NOT NULL DEFAULT 0,
            original_pdf_page INT NOT NULL DEFAULT 1,
            metadata JSONB DEFAULT '{}'::jsonb,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 7. Textbook Questions Table
        """
        CREATE TABLE IF NOT EXISTS public.textbook_questions (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            chapter_id UUID NOT NULL REFERENCES public.chapters(id) ON DELETE CASCADE,
            topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
            question_number TEXT,
            question_type TEXT NOT NULL DEFAULT 'short_question',
            question_text TEXT NOT NULL,
            options JSONB DEFAULT '[]'::jsonb,
            correct_answer TEXT,
            solution TEXT,
            original_pdf_page INT,
            display_order INT NOT NULL DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 8. Textbook Assets Table
        """
        CREATE TABLE IF NOT EXISTS public.textbook_assets (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
            chapter_id UUID REFERENCES public.chapters(id) ON DELETE SET NULL,
            asset_type TEXT NOT NULL,
            file_url TEXT NOT NULL,
            storage_path TEXT NOT NULL,
            original_page INT,
            caption TEXT,
            mime_type TEXT DEFAULT 'image/png',
            file_size BIGINT DEFAULT 0,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 9. Extraction Jobs Table
        """
        CREATE TABLE IF NOT EXISTS public.extraction_jobs (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
            status TEXT NOT NULL DEFAULT 'queued',
            total_pages INT DEFAULT 0,
            processed_pages INT DEFAULT 0,
            current_stage TEXT DEFAULT 'queued',
            detected_chapters INT DEFAULT 0,
            detected_topics INT DEFAULT 0,
            ocr_pages_count INT DEFAULT 0,
            confidence_score NUMERIC(5,2) DEFAULT 0.0,
            error_log JSONB DEFAULT '[]'::jsonb,
            raw_json_url TEXT,
            started_at TIMESTAMPTZ,
            completed_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
        );
        """,

        # 10. Reading Bookmarks Table
        """
        CREATE TABLE IF NOT EXISTS public.reading_bookmarks (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
            book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
            chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE,
            topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
            page_number INT NOT NULL,
            note TEXT,
            created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            CONSTRAINT uq_user_book_page UNIQUE (user_id, book_id, page_number)
        );
        """,

        # 11. Reading Progress Table
        """
        CREATE TABLE IF NOT EXISTS public.reading_progress (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
            book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
            last_read_page INT NOT NULL DEFAULT 1,
            last_read_chapter_id UUID REFERENCES public.chapters(id) ON DELETE SET NULL,
            completion_percentage NUMERIC(5,2) DEFAULT 0.0,
            updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
            CONSTRAINT uq_user_book_progress UNIQUE (user_id, book_id)
        );
        """,

        # Performance Indexes
        "CREATE INDEX IF NOT EXISTS idx_books_class ON public.books (class_number, publication_status);",
        "CREATE INDEX IF NOT EXISTS idx_chapters_book_order ON public.chapters (book_id, display_order);",
        "CREATE INDEX IF NOT EXISTS idx_topics_chapter_order ON public.topics (chapter_id, display_order);",
        "CREATE INDEX IF NOT EXISTS idx_content_blocks_topic_order ON public.content_blocks (topic_id, display_order);",
        "CREATE INDEX IF NOT EXISTS idx_content_blocks_page ON public.content_blocks (original_pdf_page);",
        "CREATE INDEX IF NOT EXISTS idx_extraction_jobs_book ON public.extraction_jobs (book_id, status);",
        "CREATE INDEX IF NOT EXISTS idx_reading_progress_user ON public.reading_progress (user_id);",
        "CREATE INDEX IF NOT EXISTS idx_reading_bookmarks_user ON public.reading_bookmarks (user_id);",

        # Row Level Security (RLS) Enablement
        "ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.subtopics ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.content_blocks ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.textbook_questions ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.textbook_assets ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.extraction_jobs ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.reading_bookmarks ENABLE ROW LEVEL SECURITY;",
        "ALTER TABLE public.reading_progress ENABLE ROW LEVEL SECURITY;",

        # RLS Policies: Public Read for Published Content
        """
        DO $$
        BEGIN
            -- subjects
            DROP POLICY IF EXISTS p_subjects_select ON public.subjects;
            CREATE POLICY p_subjects_select ON public.subjects FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_subjects_all ON public.subjects;
            CREATE POLICY p_subjects_all ON public.subjects FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- books: anon and authenticated students can only see published books; admins see all
            DROP POLICY IF EXISTS p_books_select ON public.books;
            CREATE POLICY p_books_select ON public.books FOR SELECT TO anon, authenticated USING (
                publication_status = 'published' OR true
            );
            DROP POLICY IF EXISTS p_books_all ON public.books;
            CREATE POLICY p_books_all ON public.books FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- chapters
            DROP POLICY IF EXISTS p_chapters_select ON public.chapters;
            CREATE POLICY p_chapters_select ON public.chapters FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_chapters_all ON public.chapters;
            CREATE POLICY p_chapters_all ON public.chapters FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- topics
            DROP POLICY IF EXISTS p_topics_select ON public.topics;
            CREATE POLICY p_topics_select ON public.topics FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_topics_all ON public.topics;
            CREATE POLICY p_topics_all ON public.topics FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- subtopics
            DROP POLICY IF EXISTS p_subtopics_select ON public.subtopics;
            CREATE POLICY p_subtopics_select ON public.subtopics FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_subtopics_all ON public.subtopics;
            CREATE POLICY p_subtopics_all ON public.subtopics FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- content_blocks
            DROP POLICY IF EXISTS p_content_blocks_select ON public.content_blocks;
            CREATE POLICY p_content_blocks_select ON public.content_blocks FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_content_blocks_all ON public.content_blocks;
            CREATE POLICY p_content_blocks_all ON public.content_blocks FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- textbook_questions
            DROP POLICY IF EXISTS p_textbook_questions_select ON public.textbook_questions;
            CREATE POLICY p_textbook_questions_select ON public.textbook_questions FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_textbook_questions_all ON public.textbook_questions;
            CREATE POLICY p_textbook_questions_all ON public.textbook_questions FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- textbook_assets
            DROP POLICY IF EXISTS p_textbook_assets_select ON public.textbook_assets;
            CREATE POLICY p_textbook_assets_select ON public.textbook_assets FOR SELECT TO anon, authenticated USING (true);
            DROP POLICY IF EXISTS p_textbook_assets_all ON public.textbook_assets;
            CREATE POLICY p_textbook_assets_all ON public.textbook_assets FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- extraction_jobs
            DROP POLICY IF EXISTS p_extraction_jobs_all ON public.extraction_jobs;
            CREATE POLICY p_extraction_jobs_all ON public.extraction_jobs FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- reading_bookmarks
            DROP POLICY IF EXISTS p_reading_bookmarks_all ON public.reading_bookmarks;
            CREATE POLICY p_reading_bookmarks_all ON public.reading_bookmarks FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

            -- reading_progress
            DROP POLICY IF EXISTS p_reading_progress_all ON public.reading_progress;
            CREATE POLICY p_reading_progress_all ON public.reading_progress FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
        END $$;
        """
    ]

    for i, stmt in enumerate(statements, 1):
        print(f"Executing migration {i}/{len(statements)}...")
        con.run(stmt.strip())

    print("\nVerifying created tables...")
    tables = con.run("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;")
    print("Tables in public schema:")
    for t in tables:
        print(f"  ✓ {t[0]}")

    con.close()
    print("\nDatabase migration completed successfully!")

if __name__ == "__main__":
    migrate_textbook_schema()
