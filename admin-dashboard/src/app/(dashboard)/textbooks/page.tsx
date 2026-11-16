'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import {
  BookOpen,
  Plus,
  Search,
  Filter,
  CheckCircle2,
  Clock,
  Eye,
  Trash2,
  Layers,
  FileText,
  AlertCircle,
  ExternalLink,
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
  group_type: string;
  book_type: string;
  extraction_status: string;
  publication_status: 'draft' | 'reviewing' | 'published' | 'archived';
  chapters_count: string;
  topics_count: string;
  created_at: string;
}

export default function TextbooksLibraryPage() {
  const [books, setBooks] = useState<BookItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedClass, setSelectedClass] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [publishingId, setPublishingId] = useState<string | null>(null);

  const fetchBooks = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (selectedClass !== 'all') params.set('class', selectedClass);
      if (selectedStatus !== 'all') params.set('status', selectedStatus);
      if (search.trim()) params.set('search', search.trim());

      const res = await fetch(`/api/textbooks?${params.toString()}`);
      const data = await res.json();
      if (data.books) {
        setBooks(data.books);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBooks();
  }, [selectedClass, selectedStatus]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchBooks();
  };

  const togglePublishStatus = async (book: BookItem) => {
    const newStatus = book.publication_status === 'published' ? 'draft' : 'published';
    setPublishingId(book.id);
    try {
      const res = await fetch(`/api/textbooks/${book.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ publication_status: newStatus }),
      });
      if (res.ok) {
        fetchBooks();
      }
    } catch (err) {
      console.error(err);
    } finally {
      setPublishingId(null);
    }
  };

  const handleDeleteBook = async (id: string, title: string) => {
    if (!confirm(`Are you sure you want to delete "${title}"? All extracted chapters and topics will be removed.`)) {
      return;
    }
    try {
      const res = await fetch(`/api/textbooks/${id}`, { method: 'DELETE' });
      if (res.ok) {
        fetchBooks();
      }
    } catch (err) {
      console.error(err);
    }
  };

  // Metrics
  const totalBooks = books.length;
  const publishedCount = books.filter((b) => b.publication_status === 'published').length;
  const draftCount = books.filter((b) => b.publication_status !== 'published').length;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-sm">
        <div>
          <div className="flex items-center space-x-2 text-amber-400 font-semibold text-xs tracking-wider uppercase mb-1">
            <BookOpen className="w-4 h-4" />
            <span>Curriculum Management</span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Textbook Library & Digital Books</h1>
          <p className="text-sm text-slate-400 mt-1">
            Manage official KPK Textbook Board digital books, review automated PDF extractions, and publish to the mobile application.
          </p>
        </div>
        <Link
          href="/textbooks/upload"
          className="inline-flex items-center justify-center space-x-2 px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-sm shadow-lg shadow-emerald-600/20 transition-all shrink-0"
        >
          <Plus className="w-4 h-4" />
          <span>Upload New Book PDF</span>
        </Link>
      </div>

      {/* Metrics Banner */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center space-x-4">
          <div className="w-12 h-12 rounded-lg bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400">
            <Layers className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Total Registered</p>
            <p className="text-2xl font-bold text-white mt-0.5">{totalBooks}</p>
          </div>
        </div>
        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center space-x-4">
          <div className="w-12 h-12 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Published on Mobile</p>
            <p className="text-2xl font-bold text-emerald-400 mt-0.5">{publishedCount}</p>
          </div>
        </div>
        <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl flex items-center space-x-4">
          <div className="w-12 h-12 rounded-lg bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400">
            <Clock className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-medium text-slate-400 uppercase tracking-wider">Draft / In Review</p>
            <p className="text-2xl font-bold text-amber-400 mt-0.5">{draftCount}</p>
          </div>
        </div>
      </div>

      {/* Controls & Filter Bar */}
      <div className="bg-slate-900 border border-slate-800 p-4 rounded-xl flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <form onSubmit={handleSearchSubmit} className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 absolute left-3.5 top-3 text-slate-400" />
          <input
            type="text"
            placeholder="Search textbook title, subject, or grade..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-950 border border-slate-800 rounded-lg text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-blue-500"
          />
        </form>

        <div className="flex flex-wrap items-center gap-3">
          {/* Class Filter */}
          <div className="flex items-center space-x-2">
            <Filter className="w-3.5 h-3.5 text-slate-400" />
            <select
              value={selectedClass}
              onChange={(e) => setSelectedClass(e.target.value)}
              className="bg-slate-950 border border-slate-800 text-xs text-slate-200 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500"
            >
              <option value="all">All Grades (1–12)</option>
              {Array.from({ length: 12 }, (_, i) => i + 1).map((c) => (
                <option key={c} value={c}>
                  Class {c}
                </option>
              ))}
            </select>
          </div>

          {/* Status Filter */}
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className="bg-slate-950 border border-slate-800 text-xs text-slate-200 rounded-lg px-3 py-2 focus:outline-none focus:border-blue-500"
          >
            <option value="all">All Statuses</option>
            <option value="published">Published</option>
            <option value="draft">Draft</option>
            <option value="reviewing">Under Review</option>
          </select>
        </div>
      </div>

      {/* Books Table */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/60 border-b border-slate-800 text-xs font-semibold text-slate-400 uppercase tracking-wider">
              <tr>
                <th className="px-6 py-4">Textbook Details</th>
                <th className="px-6 py-4">Grade & Subject</th>
                <th className="px-6 py-4">Curriculum Units</th>
                <th className="px-6 py-4">Extraction</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/80">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    <div className="inline-block w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mb-2"></div>
                    <p>Loading textbook catalog...</p>
                  </td>
                </tr>
              ) : books.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    <AlertCircle className="w-8 h-8 text-slate-500 mx-auto mb-2" />
                    <p className="font-semibold text-slate-300">No textbooks found</p>
                    <p className="text-xs text-slate-500 mt-1">Upload a PDF textbook to start automated extraction.</p>
                  </td>
                </tr>
              ) : (
                books.map((b) => (
                  <tr key={b.id} className="hover:bg-slate-800/40 transition-colors">
                    <td className="px-6 py-4">
                      <div>
                        <p className="font-semibold text-white hover:text-blue-400 transition-colors">
                          {b.title}
                        </p>
                        {b.title_urdu && (
                          <p className="text-xs text-slate-400 font-urdu">{b.title_urdu}</p>
                        )}
                        <p className="text-xs text-slate-500 mt-0.5">
                          {b.board_name} • Edition {b.edition}
                        </p>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-block px-2 py-0.5 rounded text-xs font-semibold bg-blue-500/10 text-blue-400 border border-blue-500/20 mb-1">
                        Class {b.class_number}
                      </span>
                      <p className="text-xs font-medium text-slate-300">{b.subject_name}</p>
                      <p className="text-[11px] text-slate-500 capitalize">{b.group_type} Group</p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="font-medium text-white">{b.chapters_count || 0} Units</p>
                      <p className="text-xs text-slate-500">{b.topics_count || 0} Topics • {b.total_pages} Pages</p>
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                          b.extraction_status === 'completed'
                            ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                            : b.extraction_status === 'processing'
                            ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20 animate-pulse'
                            : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                        }`}
                      >
                        {b.extraction_status === 'completed' ? 'Extracted' : b.extraction_status}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                          b.publication_status === 'published'
                            ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                            : 'bg-slate-800 text-slate-400 border border-slate-700'
                        }`}
                      >
                        {b.publication_status === 'published' ? 'Live on App' : 'Draft'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      <Link
                        href={`/textbooks/${b.id}/preview`}
                        className="inline-flex items-center space-x-1 px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-blue-600 hover:text-white text-xs font-medium text-slate-300 transition-colors border border-slate-700/80"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>Preview & Edit</span>
                      </Link>

                      <button
                        onClick={() => togglePublishStatus(b)}
                        disabled={publishingId === b.id}
                        className={`inline-flex items-center space-x-1 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors border ${
                          b.publication_status === 'published'
                            ? 'bg-amber-950/40 text-amber-300 border-amber-800/60 hover:bg-amber-900/50'
                            : 'bg-emerald-950/40 text-emerald-300 border-emerald-800/60 hover:bg-emerald-900/50'
                        }`}
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        <span>{b.publication_status === 'published' ? 'Unpublish' : 'Publish'}</span>
                      </button>

                      <button
                        onClick={() => handleDeleteBook(b.id, b.title)}
                        className="inline-flex items-center p-1.5 rounded-lg bg-slate-800 hover:bg-rose-900/50 hover:text-rose-300 text-slate-400 border border-slate-700/80 transition-colors"
                        title="Delete Book"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
