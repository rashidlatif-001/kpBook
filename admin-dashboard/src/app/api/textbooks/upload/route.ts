import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import { getCurrentAdmin } from '@/lib/auth';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { spawn } from 'child_process';

export async function POST(request: Request) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    const formData = await request.formData();
    const file = formData.get('file') as File | null;
    const title = (formData.get('title') as string) || '';
    const titleUrdu = (formData.get('title_urdu') as string) || '';
    const classNumber = (formData.get('class_number') as string) || '9';
    const subjectName = (formData.get('subject_name') as string) || 'General';
    const boardName = (formData.get('board_name') as string) || 'Khyber Pakhtunkhwa Textbook Board, Peshawar';
    const publisher = (formData.get('publisher') as string) || 'KPK Textbook Board';
    const edition = (formData.get('edition') as string) || '2024–25';
    const groupType = (formData.get('group_type') as string) || 'Science';
    const bookType = (formData.get('book_type') as string) || 'book';

    if (!file) {
      return NextResponse.json({ error: 'PDF file is required' }, { status: 400 });
    }
    if (!title.trim()) {
      return NextResponse.json({ error: 'Book title is required' }, { status: 400 });
    }

    // 1. Convert file to buffer and compute SHA-256
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    const fileHash = crypto.createHash('sha256').update(buffer).digest('hex');
    const fileSizeFormatted = `${(buffer.length / (1024 * 1024)).toFixed(1)} MB`;

    // 2. Duplicate Detection
    const existing = await query<any>(
      'SELECT id, title, publication_status FROM public.books WHERE file_hash = $1',
      [fileHash]
    );

    if (existing && existing.length > 0) {
      return NextResponse.json(
        {
          error: `Duplicate Textbook: A book with identical file content has already been uploaded as "${existing[0].title}".`,
          existing_id: existing[0].id,
          file_hash: fileHash,
        },
        { status: 409 }
      );
    }

    // 3. Save PDF securely on filesystem
    const uploadsDir = path.join(process.cwd(), 'public', 'uploads', 'textbooks');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    const savedPdfPath = path.join(uploadsDir, `${fileHash}.pdf`);
    fs.writeFileSync(savedPdfPath, buffer);

    // 4. Register Book in database
    const bookRows = await query<any>(
      `INSERT INTO public.books (
        title, title_urdu, class_number, subject_name, board_name,
        publisher, edition, group_type, book_type, file_hash,
        total_pages, file_size, original_pdf_path, extraction_status, publication_status
      ) VALUES (
        $1, $2, $3, $4, $5,
        $6, $7, $8, $9, $10,
        0, $11, $12, 'processing', 'draft'
      ) RETURNING id;`,
      [
        title.trim(),
        titleUrdu.trim(),
        parseInt(classNumber, 10),
        subjectName.trim(),
        boardName.trim(),
        publisher.trim(),
        edition.trim(),
        groupType,
        bookType,
        fileHash,
        fileSizeFormatted,
        savedPdfPath,
      ]
    );

    const bookId = bookRows[0].id;

    // 5. Create Extraction Job
    const jobRows = await query<any>(
      `INSERT INTO public.extraction_jobs (
        book_id, status, current_stage, started_at
      ) VALUES ($1, 'processing', 'inspecting', now())
      RETURNING id;`,
      [bookId]
    );

    const jobId = jobRows[0].id;

    // 6. Spawn Python extraction worker in background
    const rootDir = path.resolve(process.cwd(), '..');
    const scriptPath = path.join(rootDir, 'scripts', 'pdf_extractor.py');

    const worker = spawn(
      'python',
      [scriptPath, '--pdf', savedPdfPath, '--book-id', bookId, '--job-id', jobId],
      {
        cwd: rootDir,
        detached: true,
        stdio: 'ignore',
      }
    );
    worker.unref();

    console.log(`[EXTRACTION WORKER] Spawned PID ${worker.pid} for Book ${bookId}, Job ${jobId}`);

    return NextResponse.json({
      success: true,
      book_id: bookId,
      job_id: jobId,
      file_hash: fileHash,
      file_size: fileSizeFormatted,
      message: 'PDF uploaded and background extraction engine started.',
    });
  } catch (error: any) {
    console.error('Upload & extract error:', error);
    return NextResponse.json(
      { error: 'Failed to upload and start extraction', details: error.message },
      { status: 500 }
    );
  }
}
