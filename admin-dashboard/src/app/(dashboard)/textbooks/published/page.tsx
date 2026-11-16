'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import {
  CheckCircle2,
  BookOpen,
  ArrowLeft,
  Eye,
  Smartphone,
  ExternalLink,
  Layers,
  Sparkles,
} from 'lucide-react';

interface BookItem {
  id: string;
  title: string;
  title_urdu: string;
  class_number: number;
  subject_name: string;
  board_name: string;
  edition: string;
  total_pages: number;
  file_size: string;
  chapters_count: string;
  topics_count: string;
}

export default function PublishedBooksPage() {
  const [books, setBooks] = useState<BookItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadPublished() {
      try {
        const res = await fetch('/api/textbooks?status=published');
        const data = await res.json();
        if (data.books) {
          setBooks(data.books);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    loadPublished();
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-sm">
        <div>
          <Link
            href="/textbooks"
            className="inline-flex items-center space-x-1.5 text-xs font-medium text-slate-400 hover:text-white transition-colors mb-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Textbook Library</span>
          </Link>
          <div className="flex items-center space-x-2 text-emerald-400 font-semibold text-xs tracking-wider uppercase mb-1">
            <CheckCircle2 className="w-4 h-4" />
            <span>Live Mobile Curriculum</span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Published Mobile Textbooks</h1>
          <p className="text-sm text-slate-400 mt-1">
            These verified curriculum textbooks are actively synchronized and readable by students in the KPK E-Textbooks Flutter app.
          </p>
        </div>
      </div>

      {/* Grid of Published Books */}
      {loading ? (
        <div className="py-24 text-center">
          <div className="inline-block w-8 h-8 border-3 border-emerald-500 border-t-transparent rounded-full animate-spin mb-3"></div>
          <p className="text-slate-400 font-medium text-sm">Loading published textbooks...</p>
        </div>
      ) : books.length === 0 ? (
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-16 text-center text-slate-400">
          <BookOpen className="w-10 h-10 text-slate-500 mx-auto mb-3" />
          <h3 className="text-lg font-bold text-white">No books are currently published</h3>
          <p className="text-sm text-slate-400 mt-1 max-w-md mx-auto">
            Uploaded books remain in Draft mode until approved. Review a book in the Textbook Library and click &quot;Approve &amp; Publish&quot;.
          </p>
          <Link
            href="/textbooks"
            className="inline-flex items-center space-x-2 mt-4 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-medium text-xs transition-colors"
          >
            <span>Go to Textbook Library</span>
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {books.map((b) => (
            <div
              key={b.id}
              className="bg-slate-900 border border-slate-800 hover:border-slate-700 rounded-2xl p-5 shadow-sm transition-all flex flex-col justify-between"
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <span className="px-2.5 py-0.5 rounded text-xs font-bold bg-blue-500/20 text-blue-300 border border-blue-400/30">
                    Class {b.class_number}
                  </span>
                  <span className="flex items-center space-x-1 text-emerald-400 text-[11px] font-semibold bg-emerald-950/60 px-2 py-0.5 rounded-full border border-emerald-800/80">
                    <Smartphone className="w-3 h-3" />
                    <span>Live in App</span>
                  </span>
                </div>

                <h3 className="text-base font-bold text-white tracking-tight leading-snug">{b.title}</h3>
                {b.title_urdu && (
                  <p className="text-xs text-slate-400 font-urdu mt-0.5">{b.title_urdu}</p>
                )}

                <div className="mt-4 pt-3 border-t border-slate-800/80 grid grid-cols-2 gap-2 text-xs text-slate-400">
                  <div>
                    <span className="text-slate-500 block text-[10px] uppercase">Subject</span>
                    <span className="font-semibold text-slate-200">{b.subject_name}</span>
                  </div>
                  <div>
                    <span className="text-slate-500 block text-[10px] uppercase">Curriculum</span>
                    <span className="font-semibold text-slate-200">{b.chapters_count || 0} Units</span>
                  </div>
                </div>
              </div>

              <div className="mt-5 pt-3 border-t border-slate-800/80 flex items-center justify-between">
                <span className="text-xs text-slate-500">{b.total_pages} Pages</span>
                <Link
                  href={`/textbooks/${b.id}/preview`}
                  className="inline-flex items-center space-x-1 text-xs font-semibold text-blue-400 hover:text-blue-300"
                >
                  <Eye className="w-3.5 h-3.5" />
                  <span>Preview & Edit</span>
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
