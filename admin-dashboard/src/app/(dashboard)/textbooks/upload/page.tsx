'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import {
  UploadCloud,
  FileText,
  CheckCircle,
  AlertCircle,
  ArrowLeft,
  Loader2,
  BookOpen,
  Sparkles,
  ShieldCheck,
} from 'lucide-react';

export default function UploadTextbookPage() {
  const router = useRouter();

  const [file, setFile] = useState<File | null>(null);
  const [title, setTitle] = useState('');
  const [titleUrdu, setTitleUrdu] = useState('');
  const [classNumber, setClassNumber] = useState('9');
  const [subjectName, setSubjectName] = useState('Physics');
  const [boardName, setBoardName] = useState('Khyber Pakhtunkhwa Textbook Board, Peshawar');
  const [publisher, setPublisher] = useState('KPK Textbook Board');
  const [edition, setEdition] = useState('2024–25');
  const [groupType, setGroupType] = useState('Science');
  const [bookType, setBookType] = useState('book');

  const [uploading, setUploading] = useState(false);
  const [progressStage, setProgressStage] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [successBookId, setSuccessBookId] = useState<string | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];
      if (!selectedFile.name.toLowerCase().endsWith('.pdf')) {
        setError('Only PDF documents are supported.');
        return;
      }
      setFile(selectedFile);
      setError(null);

      // Auto-populate title if empty
      if (!title) {
        const cleanName = selectedFile.name.replace(/\.[^/.]+$/, '').replace(/[-_]/g, ' ');
        setTitle(cleanName);
      }
    }
  };

  const calculateSha256 = async (blob: Blob): Promise<string> => {
    const buffer = await blob.arrayBuffer();
    const hashBuffer = await crypto.subtle.digest('SHA-256', buffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!file) {
      setError('Please select a PDF textbook to upload.');
      return;
    }
    if (!title.trim()) {
      setError('Book title is required.');
      return;
    }

    setUploading(true);
    setError(null);

    try {
      setProgressStage('Calculating SHA-256 integrity hash & verifying file...');
      const fileHash = await calculateSha256(file);
      const fileSizeFormatted = `${(file.size / (1024 * 1024)).toFixed(1)} MB`;

      // 1. Direct Cloud Upload (Cloudflare R2 or Supabase - Bypasses Vercel 4.5MB Serverless Limit)
      setProgressStage(`Preparing direct cloud storage upload for ${fileSizeFormatted} PDF...`);
      const prepRes = await fetch('/api/storage/upload-url', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ filename: `${fileHash}.pdf`, contentType: 'application/pdf' }),
      });

      if (!prepRes.ok) {
        throw new Error('Failed to obtain cloud storage upload URL.');
      }

      const prepData = await prepRes.json();
      const providerLabel = prepData.provider === 'r2' ? 'Cloudflare R2' : 'Cloud Storage';
      setProgressStage(`Uploading ${fileSizeFormatted} PDF directly to ${providerLabel}...`);

      const storageRes = await fetch(prepData.uploadUrl, {
        method: prepData.provider === 'r2' ? 'PUT' : 'POST',
        headers: prepData.headers || { 'Content-Type': 'application/pdf' },
        body: file,
      });

      if (!storageRes.ok) {
        const errJson = await storageRes.json().catch(() => ({}));
        throw new Error(errJson.message || `Cloud storage upload failed (HTTP ${storageRes.status}).`);
      }

      const publicPdfUrl = prepData.publicUrl;

      // 2. Register textbook record in database via lightweight JSON
      setProgressStage('Registering textbook metadata and queuing extraction job...');
      const regRes = await fetch('/api/textbooks/upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: title.trim(),
          title_urdu: titleUrdu.trim(),
          class_number: classNumber,
          subject_name: subjectName.trim(),
          board_name: boardName.trim(),
          publisher: publisher.trim(),
          edition: edition.trim(),
          group_type: groupType,
          book_type: bookType,
          file_hash: fileHash,
          file_size: fileSizeFormatted,
          pdf_url: publicPdfUrl,
        }),
      });

      let regData: any = {};
      try {
        regData = await regRes.json();
      } catch {
        const rawText = await regRes.text().catch(() => '');
        throw new Error(rawText || 'Server returned an invalid non-JSON response.');
      }

      if (!regRes.ok) {
        throw new Error(regData.error || 'Failed to upload textbook');
      }

      const bookId = regData.book_id;
      setSuccessBookId(bookId);

      setProgressStage('Textbook successfully queued! Redirecting to preview editor...');
      setTimeout(() => {
        router.push(`/textbooks/${bookId}/preview`);
      }, 1500);

    } catch (err: any) {
      console.error(err);
      setError(err.message || 'An error occurred during upload.');
      setUploading(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Back button */}
      <div>
        <Link
          href="/textbooks"
          className="inline-flex items-center space-x-1.5 text-xs font-medium text-slate-400 hover:text-white transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Textbook Library</span>
        </Link>
      </div>

      {/* Header */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-sm">
        <div className="flex items-center space-x-2 text-emerald-400 font-semibold text-xs tracking-wider uppercase mb-1">
          <UploadCloud className="w-4 h-4" />
          <span>PDF-to-Digital Ingestion</span>
        </div>
        <h1 className="text-2xl font-bold text-white tracking-tight">Upload & Extract Educational Textbook</h1>
        <p className="text-sm text-slate-400 mt-1">
          Select an official KPTBB curriculum book or study guide in PDF format. The extraction engine will automatically parse chapters, topics, formulas, tables, and SLOs.
        </p>
      </div>

      {/* Error Message */}
      {error && (
        <div className="p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-300 text-sm flex items-start space-x-3">
          <AlertCircle className="w-5 h-5 shrink-0 mt-0.5" />
          <div>
            <p className="font-semibold">Upload Notice</p>
            <p className="text-xs text-rose-400 mt-0.5">{error}</p>
          </div>
        </div>
      )}

      {/* Upload Form */}
      <form onSubmit={handleSubmit} className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6 shadow-sm">
        {/* PDF File Drag & Drop Box */}
        <div>
          <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
            Textbook PDF Document
          </label>
          <div className="border-2 border-dashed border-slate-700 hover:border-blue-500/80 rounded-2xl p-8 text-center transition-colors bg-slate-950/40">
            <input
              type="file"
              accept=".pdf"
              onChange={handleFileChange}
              disabled={uploading}
              className="hidden"
              id="pdf-upload"
            />
            <label htmlFor="pdf-upload" className="cursor-pointer flex flex-col items-center">
              <div className="w-16 h-16 rounded-2xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 mb-3 shadow-lg shadow-blue-500/10">
                <UploadCloud className="w-8 h-8" />
              </div>
              {file ? (
                <div>
                  <p className="font-semibold text-white text-base">{file.name}</p>
                  <p className="text-xs text-emerald-400 font-medium mt-1">
                    {(file.size / (1024 * 1024)).toFixed(2)} MB • Ready for processing
                  </p>
                  <span className="inline-block mt-3 px-3 py-1 rounded bg-slate-800 text-xs text-slate-300 hover:bg-slate-700">
                    Change PDF
                  </span>
                </div>
              ) : (
                <div>
                  <p className="font-semibold text-white text-base">Drag & drop textbook PDF or click to browse</p>
                  <p className="text-xs text-slate-500 mt-1">Supports official KPK Textbook Board books up to 150 MB</p>
                  <span className="inline-block mt-3 px-4 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-xs text-white font-medium shadow-md shadow-blue-600/20">
                    Select File
                  </span>
                </div>
              )}
            </label>
          </div>
        </div>

        {/* Metadata Fields */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Textbook Title (English) *</label>
            <input
              type="text"
              required
              placeholder="e.g. Physics for Class IX"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Textbook Title (Urdu)</label>
            <input
              type="text"
              placeholder="e.g. طبیعیات برائے جماعت نہم"
              value={titleUrdu}
              onChange={(e) => setTitleUrdu(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500 font-urdu text-right"
              dir="rtl"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Class / Grade *</label>
            <select
              value={classNumber}
              onChange={(e) => setClassNumber(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            >
              {Array.from({ length: 12 }, (_, i) => i + 1).map((c) => (
                <option key={c} value={c}>
                  Class {c} ({c <= 5 ? 'Primary' : c <= 8 ? 'Middle' : c <= 10 ? 'Matric' : 'Intermediate'})
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Subject Name *</label>
            <input
              type="text"
              required
              placeholder="e.g. Physics, Chemistry, Biology, Urdu"
              value={subjectName}
              onChange={(e) => setSubjectName(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Curriculum Group</label>
            <select
              value={groupType}
              onChange={(e) => setGroupType(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            >
              <option value="Science">Science Group</option>
              <option value="Arts">Arts / Humanities Group</option>
              <option value="Compulsory">Compulsory Subjects</option>
              <option value="General">General Group</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Publication Type</label>
            <select
              value={bookType}
              onChange={(e) => setBookType(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            >
              <option value="book">Official Textbook</option>
              <option value="guide">Solved SLO Key Book / Guide</option>
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Board / Authority</label>
            <input
              type="text"
              value={boardName}
              onChange={(e) => setBoardName(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1">Curriculum Edition</label>
            <input
              type="text"
              value={edition}
              onChange={(e) => setEdition(e.target.value)}
              disabled={uploading}
              className="w-full px-3.5 py-2.5 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 focus:outline-none focus:border-blue-500"
            />
          </div>
        </div>

        {/* Progress Indicator */}
        {uploading && (
          <div className="p-4 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-300 space-y-2">
            <div className="flex items-center space-x-2 font-medium text-sm">
              <Loader2 className="w-4 h-4 animate-spin text-blue-400" />
              <span>{progressStage}</span>
            </div>
            <div className="w-full bg-slate-800 h-1.5 rounded-full overflow-hidden">
              <div className="bg-blue-500 h-full rounded-full animate-pulse w-3/4"></div>
            </div>
          </div>
        )}

        {/* Submit Actions */}
        <div className="pt-4 border-t border-slate-800 flex items-center justify-end space-x-3">
          <Link
            href="/textbooks"
            className="px-5 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 font-medium text-sm transition-colors"
          >
            Cancel
          </Link>
          <button
            type="submit"
            disabled={uploading}
            className="inline-flex items-center space-x-2 px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-sm shadow-lg shadow-emerald-600/20 transition-all disabled:opacity-50"
          >
            {uploading ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                <span>Processing...</span>
              </>
            ) : (
              <>
                <Sparkles className="w-4 h-4" />
                <span>Start Extraction & Structuring</span>
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
