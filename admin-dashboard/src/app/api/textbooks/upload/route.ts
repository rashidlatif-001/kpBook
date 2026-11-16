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
    const contentType = request.headers.get('content-type') || '';
    let fileHash = '';
    let fileSizeFormatted = '';
    let pdfUrl = '';
    let title = '';
    let titleUrdu = '';
    let classNumber = '9';
    let subjectName = 'General';
    let boardName = 'Khyber Pakhtunkhwa Textbook Board, Peshawar';
    let publisher = 'KPK Textbook Board';
    let edition = '2024–25';
    let groupType = 'Science';
    let bookType = 'book';

    if (contentType.includes('application/json')) {
      const body = await request.json();
      fileHash = body.file_hash || '';
      fileSizeFormatted = body.file_size || '0 MB';
      pdfUrl = body.pdf_url || '';
      title = body.title || '';
      titleUrdu = body.title_urdu || '';
      classNumber = String(body.class_number || '9');
      subjectName = body.subject_name || 'General';
      boardName = body.board_name || 'Khyber Pakhtunkhwa Textbook Board, Peshawar';
      publisher = body.publisher || 'KPK Textbook Board';
      edition = body.edition || '2024–25';
      groupType = body.group_type || 'Science';
      bookType = body.book_type || 'book';
    } else {
      const formData = await request.formData();
      const file = formData.get('file') as File | null;
      title = (formData.get('title') as string) || '';
      titleUrdu = (formData.get('title_urdu') as string) || '';
      classNumber = (formData.get('class_number') as string) || '9';
      subjectName = (formData.get('subject_name') as string) || 'General';
      boardName = (formData.get('board_name') as string) || 'Khyber Pakhtunkhwa Textbook Board, Peshawar';
      publisher = (formData.get('publisher') as string) || 'KPK Textbook Board';
      edition = (formData.get('edition') as string) || '2024–25';
      groupType = (formData.get('group_type') as string) || 'Science';
      bookType = (formData.get('book_type') as string) || 'book';

      if (!file) {
        return NextResponse.json({ error: 'PDF file is required' }, { status: 400 });
      }

      const bytes = await file.arrayBuffer();
      const buffer = Buffer.from(bytes);
      fileHash = crypto.createHash('sha256').update(buffer).digest('hex');
      fileSizeFormatted = `${(buffer.length / (1024 * 1024)).toFixed(1)} MB`;

      const uploadsDir = path.join(process.cwd(), 'public', 'uploads', 'textbooks');
      try {
        if (!fs.existsSync(uploadsDir)) {
          fs.mkdirSync(uploadsDir, { recursive: true });
        }
        const savedPdfPath = path.join(uploadsDir, `${fileHash}.pdf`);
        fs.writeFileSync(savedPdfPath, buffer);
        pdfUrl = savedPdfPath;
      } catch {
        pdfUrl = `https://tsqypxgfaajwqcgtfdkq.supabase.co/storage/v1/object/public/textbooks/${fileHash}.pdf`;
      }
    }

    if (!title.trim()) {
      return NextResponse.json({ error: 'Book title is required' }, { status: 400 });
    }
    if (!fileHash) {
      return NextResponse.json({ error: 'File hash is required' }, { status: 400 });
    }

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

    // 3. Register Book in database
    const bookRows = await query<any>(
      `INSERT INTO public.books (
        title, title_urdu, class_number, subject_name, board_name,
        publisher, edition, group_type, book_type, file_hash,
        total_pages, file_size, original_pdf_path, extraction_status, publication_status
      ) VALUES (
        $1, $2, $3, $4, $5,
        $6, $7, $8, $9, $10,
        0, $11, $12, 'queued', 'draft'
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
        pdfUrl,
      ]
    );

    const bookId = bookRows[0].id;

    // 4. Create Extraction Job
    const jobRows = await query<any>(
      `INSERT INTO public.extraction_jobs (
        book_id, status, current_stage, started_at
      ) VALUES ($1, 'queued', 'queued', now())
      RETURNING id;`,
      [bookId]
    );

    const jobId = jobRows[0].id;

    // 5. Spawn background worker if local Python script exists
    const rootDir = path.resolve(process.cwd(), '..');
    const scriptPath = path.join(rootDir, 'scripts', 'pdf_extractor.py');

    if (fs.existsSync(scriptPath)) {
      try {
        const worker = spawn(
          'python',
          [scriptPath, '--pdf', pdfUrl, '--book-id', bookId, '--job-id', jobId],
          {
            cwd: rootDir,
            detached: true,
            stdio: 'ignore',
          }
        );
        worker.unref();
        console.log(`[EXTRACTION WORKER] Spawned PID ${worker.pid} for Book ${bookId}, Job ${jobId}`);
      } catch (e) {
        console.warn('Worker spawn note:', e);
      }
    }

    return NextResponse.json({
      success: true,
      book_id: bookId,
      job_id: jobId,
      file_hash: fileHash,
      file_size: fileSizeFormatted,
      pdf_url: pdfUrl,
      message: 'Textbook registered and queued for extraction.',
    });
  } catch (error: any) {
    console.error('Upload & extract error:', error);
    return NextResponse.json(
      { error: 'Failed to upload and start extraction', details: error.message },
      { status: 500 }
    );
  }
}
