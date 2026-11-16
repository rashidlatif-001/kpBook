'use client';

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import {
  FileCog,
  CheckCircle2,
  Clock,
  AlertTriangle,
  RotateCcw,
  BookOpen,
  ArrowLeft,
  ChevronRight,
  Eye,
} from 'lucide-react';

interface JobItem {
  id: string;
  book_id: string;
  book_title: string;
  subject_name: string;
  class_number: number;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  total_pages: number;
  processed_pages: number;
  current_stage: string;
  detected_chapters: number;
  detected_topics: number;
  confidence_score: string;
  error_log: any[];
  created_at: string;
  completed_at?: string;
}

export default function ExtractionJobsPage() {
  const [jobs, setJobs] = useState<JobItem[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchJobs = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/textbooks/jobs');
      const data = await res.json();
      if (data.jobs) {
        setJobs(data.jobs);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchJobs();
    const interval = setInterval(fetchJobs, 10000); // Poll every 10s
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="space-y-6">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-sm">
        <div>
          <Link
            href="/textbooks"
            className="inline-flex items-center space-x-1.5 text-xs font-medium text-slate-400 hover:text-white transition-colors mb-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Textbook Library</span>
          </Link>
          <div className="flex items-center space-x-2 text-blue-400 font-semibold text-xs tracking-wider uppercase mb-1">
            <FileCog className="w-4 h-4" />
            <span>Background Automation Pipeline</span>
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight">PDF Extraction Jobs & AI Pipeline</h1>
          <p className="text-sm text-slate-400 mt-1">
            Real-time status of document parsing, layout extraction, formula preservation, and database ingestion.
          </p>
        </div>

        <button
          onClick={fetchJobs}
          className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-xs font-medium text-slate-300 transition-colors border border-slate-700/80 shrink-0"
        >
          <RotateCcw className="w-3.5 h-3.5" />
          <span>Refresh Queue</span>
        </button>
      </div>

      {/* Jobs Table */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-300">
            <thead className="bg-slate-950/60 border-b border-slate-800 text-xs font-semibold text-slate-400 uppercase tracking-wider">
              <tr>
                <th className="px-6 py-4">Textbook Target</th>
                <th className="px-6 py-4">Job Status</th>
                <th className="px-6 py-4">Current Pipeline Stage</th>
                <th className="px-6 py-4">Detected Structure</th>
                <th className="px-6 py-4">Confidence</th>
                <th className="px-6 py-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/80">
              {loading && jobs.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    <div className="inline-block w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mb-2"></div>
                    <p>Loading background pipeline jobs...</p>
                  </td>
                </tr>
              ) : jobs.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-slate-400">
                    <CheckCircle2 className="w-8 h-8 text-emerald-500 mx-auto mb-2" />
                    <p className="font-semibold text-white">No active extraction jobs</p>
                    <p className="text-xs text-slate-500 mt-1">
                      Upload a new textbook PDF to initiate an automated parsing job.
                    </p>
                  </td>
                </tr>
              ) : (
                jobs.map((job) => (
                  <tr key={job.id} className="hover:bg-slate-800/40 transition-colors">
                    <td className="px-6 py-4">
                      <p className="font-semibold text-white">{job.book_title}</p>
                      <p className="text-xs text-slate-500">
                        Class {job.class_number} • {job.subject_name}
                      </p>
                    </td>
                    <td className="px-6 py-4">
                      <span
                        className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
                          job.status === 'completed'
                            ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                            : job.status === 'processing'
                            ? 'bg-blue-500/10 text-blue-400 border border-blue-500/20 animate-pulse'
                            : job.status === 'failed'
                            ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                            : 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                        }`}
                      >
                        {job.status}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <p className="font-medium text-slate-200 text-xs font-mono capitalize">
                        {job.current_stage.replace(/_/g, ' ')}
                      </p>
                      <p className="text-[11px] text-slate-500">
                        {job.processed_pages} of {job.total_pages || '?'} Pages Processed
                      </p>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-xs font-semibold text-white">
                        {job.detected_chapters} Chapters
                      </p>
                      <p className="text-[11px] text-slate-400">{job.detected_topics} Topics</p>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-xs font-bold text-emerald-400">
                        {job.confidence_score ? `${job.confidence_score}%` : 'N/A'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <Link
                        href={`/textbooks/${job.book_id}/preview`}
                        className="inline-flex items-center space-x-1 px-3 py-1.5 rounded-lg bg-blue-600/90 hover:bg-blue-600 text-white text-xs font-medium transition-colors"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>Preview Book</span>
                      </Link>
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
