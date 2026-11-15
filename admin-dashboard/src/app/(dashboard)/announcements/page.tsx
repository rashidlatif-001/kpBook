'use client';

import React, { useState, useEffect } from 'react';
import { Topbar } from '@/components/layout/Topbar';
import {
  Megaphone,
  Send,
  Trash2,
  Sparkles,
  Smartphone,
  CheckCircle2,
  AlertCircle,
  Clock,
  Layers,
  Tag,
  FileText,
  BadgeAlert,
  GraduationCap
} from 'lucide-react';

interface Announcement {
  id: string;
  title: string;
  message: string;
  related_class: number | null;
  type: string;
  action_label: string;
  created_at: string;
}

export default function AnnouncementsPage() {
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Form Fields
  const [title, setTitle] = useState('Mid-term Exams Preparation Guide');
  const [badgeLabel, setBadgeLabel] = useState('Curriculum 2024–25');
  const [message, setMessage] = useState(
    'Complete syllabus & model papers for all grades now fully available offline with past paper solutions.'
  );
  const [targetClass, setTargetClass] = useState('all');
  const [noticeType, setNoticeType] = useState('exam');

  const [toast, setToast] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const showToast = (type: 'success' | 'error', text: string) => {
    setToast({ type, text });
    setTimeout(() => setToast(null), 4000);
  };

  const loadAnnouncements = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/announcements');
      const data = await res.json();
      if (data.announcements) {
        setAnnouncements(data.announcements);
      }
    } catch (err: any) {
      console.error(err);
      showToast('error', 'Failed to load announcements from server.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAnnouncements();
  }, []);

  const handlePublish = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) {
      showToast('error', 'Please fill in both the title and message fields.');
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch('/api/announcements', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title,
          message,
          action_label: badgeLabel,
          related_class: targetClass,
          type: noticeType,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to publish announcement.');
      }

      showToast('success', 'Notice published successfully! The Mobile App banner will now display this update.');
      loadAnnouncements();
    } catch (err: any) {
      showToast('error', err.message || 'Error publishing notice.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to remove this announcement from the mobile app?')) {
      return;
    }

    setDeletingId(id);
    try {
      const res = await fetch(`/api/announcements?id=${id}`, { method: 'DELETE' });
      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.error || 'Failed to delete announcement.');
      }

      showToast('success', 'Announcement deleted successfully.');
      setAnnouncements((prev) => prev.filter((a) => a.id !== id));
    } catch (err: any) {
      showToast('error', err.message || 'Error deleting notice.');
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <>
      <Topbar
        title="App Announcements & Home Banner Broadcast"
        description="Publish real-time announcements, model paper alerts & exam guides to the student mobile app"
      />

      <div className="p-6 space-y-6">
        {/* Toast Alert */}
        {toast && (
          <div
            className={`p-4 rounded-xl text-sm font-semibold flex items-center space-x-2 border shadow-sm transition-all animate-in fade-in slide-in-from-top-3 ${
              toast.type === 'success'
                ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
                : 'bg-rose-50 text-rose-800 border-rose-200'
            }`}
          >
            {toast.type === 'success' ? (
              <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
            ) : (
              <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
            )}
            <span>{toast.text}</span>
          </div>
        )}

        <div className="grid grid-cols-1 xl:grid-cols-12 gap-6">
          {/* Left Column: Create & Broadcast Form (7 cols) */}
          <div className="xl:col-span-7 bg-white rounded-2xl border border-slate-200/90 p-6 shadow-xs space-y-5">
            <div className="flex items-center space-x-3 pb-4 border-b border-slate-100">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-600 to-green-500 flex items-center justify-center text-white shadow-md shadow-emerald-500/20">
                <Megaphone className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-bold text-slate-900">Broadcast New Notice</h3>
                <p className="text-xs text-slate-500">
                  Instantly updates the top featured banner on all students' mobile phones
                </p>
              </div>
            </div>

            <form onSubmit={handlePublish} className="space-y-4">
              {/* Notice Title */}
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
                  Notice Headline / Banner Title *
                </label>
                <div className="relative">
                  <input
                    type="text"
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g. Mid-term Exams Preparation Guide"
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm font-semibold text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent placeholder:text-slate-400 placeholder:font-normal"
                  />
                  <Sparkles className="w-4 h-4 text-emerald-500 absolute right-3.5 top-3 pointer-events-none" />
                </div>
              </div>

              {/* Badge Label & Target Class in Row */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5 flex items-center space-x-1">
                    <Tag className="w-3.5 h-3.5 text-slate-400" />
                    <span>Top Badge Label</span>
                  </label>
                  <input
                    type="text"
                    value={badgeLabel}
                    onChange={(e) => setBadgeLabel(e.target.value)}
                    placeholder="e.g. Curriculum 2024–25"
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5 flex items-center space-x-1">
                    <GraduationCap className="w-3.5 h-3.5 text-slate-400" />
                    <span>Target Class</span>
                  </label>
                  <select
                    value={targetClass}
                    onChange={(e) => setTargetClass(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm font-medium text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent bg-white"
                  >
                    <option value="all">All Classes (General Announcement)</option>
                    {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((c) => (
                      <option key={c} value={c}>
                        Class {c} Only
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Notice Type */}
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5 flex items-center space-x-1">
                  <BadgeAlert className="w-3.5 h-3.5 text-slate-400" />
                  <span>Category Type</span>
                </label>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  {[
                    { id: 'exam', label: 'Exam Guide' },
                    { id: 'syllabus', label: 'Syllabus Update' },
                    { id: 'notice', label: 'Board Notice' },
                    { id: 'urgent', label: 'Urgent Alert' },
                  ].map((t) => (
                    <button
                      type="button"
                      key={t.id}
                      onClick={() => setNoticeType(t.id)}
                      className={`px-3 py-2 text-xs font-bold rounded-xl border transition-all text-center ${
                        noticeType === t.id
                          ? 'bg-emerald-50 border-emerald-500 text-emerald-800 shadow-xs'
                          : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'
                      }`}
                    >
                      {t.label}
                    </button>
                  ))}
                </div>
              </div>

              {/* Message / Description */}
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5 flex items-center space-x-1">
                  <FileText className="w-3.5 h-3.5 text-slate-400" />
                  <span>Description / Full Message *</span>
                </label>
                <textarea
                  required
                  rows={3}
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Enter detailed notice information for students..."
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent placeholder:text-slate-400 leading-relaxed"
                />
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={submitting}
                className="w-full py-3 px-4 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-sm shadow-md shadow-emerald-700/25 transition-all flex items-center justify-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {submitting ? (
                  <>
                    <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                    <span>Broadcasting to Mobile App...</span>
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4" />
                    <span>Publish Notice to Mobile App</span>
                  </>
                )}
              </button>
            </form>
          </div>

          {/* Right Column: Live Mobile Banner Preview (5 cols) */}
          <div className="xl:col-span-5 space-y-4">
            <div className="bg-slate-900 rounded-2xl p-5 border border-slate-800 text-white space-y-3 shadow-md">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <Smartphone className="w-4 h-4 text-emerald-400" />
                  <span className="text-xs font-bold uppercase tracking-wider text-slate-300">
                    Live Mobile App Preview
                  </span>
                </div>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 font-semibold">
                  Home Screen
                </span>
              </div>
              <p className="text-xs text-slate-400">
                This is exactly how your banner appears on students' phones when the app launches:
              </p>

              {/* The Mobile Banner Mockup matching Flutter styling */}
              <div className="rounded-2xl p-4 shadow-lg text-white space-y-2.5 transition-all border border-emerald-400/20 bg-gradient-to-br from-[#086B3A] via-[#005129] to-[#00381B]">
                <div className="flex items-center justify-between">
                  <div className="inline-flex items-center space-x-1.5 px-2.5 py-0.5 rounded-full bg-amber-100/90 text-amber-950 text-[11px] font-extrabold shadow-xs">
                    <CheckCircle2 className="w-3 h-3 text-amber-900" />
                    <span>{badgeLabel.trim() || 'Curriculum 2024–25'}</span>
                  </div>
                  <span className="text-[9px] font-mono font-bold uppercase tracking-widest px-2 py-0.5 rounded bg-white/15 text-white">
                    LIVE NOTICE
                  </span>
                </div>

                <div>
                  <h4 className="text-base font-extrabold text-white leading-snug">
                    {title.trim() || 'Notice Headline'}
                  </h4>
                  <p className="text-xs text-emerald-100/90 leading-relaxed mt-1">
                    {message.trim() || 'Detailed notice description goes here...'}
                  </p>
                </div>

                <div className="pt-1 flex items-center justify-between text-[11px] text-emerald-200/80 border-t border-emerald-600/40">
                  <span className="flex items-center space-x-1 font-medium">
                    <GraduationCap className="w-3 h-3" />
                    <span>{targetClass === 'all' ? 'For: All Grades' : `For: Class ${targetClass}`}</span>
                  </span>
                  <span className="font-semibold text-white underline underline-offset-2">
                    Tap to Open →
                  </span>
                </div>
              </div>
            </div>

            {/* Quick Helper Notes */}
            <div className="bg-emerald-50/70 border border-emerald-200/70 rounded-xl p-4 text-xs text-emerald-950 space-y-1.5">
              <p className="font-bold flex items-center space-x-1.5 text-emerald-900">
                <Sparkles className="w-3.5 h-3.5 text-emerald-700" />
                <span>Real-Time Sync Logic:</span>
              </p>
              <p className="leading-relaxed text-emerald-800">
                1. Clicking <b>Publish Notice</b> writes directly to the <code>app_updates</code> table in Supabase.
              </p>
              <p className="leading-relaxed text-emerald-800">
                2. Student devices pull the latest announcement on launch or when they pull-down to refresh on the Home screen.
              </p>
            </div>
          </div>
        </div>

        {/* Previous Broadcasts Table */}
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-xs overflow-hidden">
          <div className="p-5 border-b border-slate-100 flex items-center justify-between">
            <div>
              <h3 className="text-base font-bold text-slate-900">Published Notices History</h3>
              <p className="text-xs text-slate-500">
                All announcements active in the Supabase database. The latest one is shown on the Home Banner.
              </p>
            </div>
            <button
              onClick={loadAnnouncements}
              className="text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 text-slate-700 transition"
            >
              Refresh List
            </button>
          </div>

          {loading ? (
            <div className="p-12 text-center text-slate-400 text-sm">
              <span className="inline-block w-5 h-5 border-2 border-slate-300 border-t-emerald-600 rounded-full animate-spin mb-2"></span>
              <p>Loading published announcements...</p>
            </div>
          ) : announcements.length === 0 ? (
            <div className="p-12 text-center text-slate-400 text-sm">
              <Layers className="w-8 h-8 text-slate-300 mx-auto mb-2" />
              <p className="font-medium text-slate-600">No published announcements found in database.</p>
              <p className="text-xs text-slate-400 mt-1">
                Fill the form above to publish your first announcement to the mobile app!
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-600 font-bold uppercase tracking-wider">
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4">Badge</th>
                    <th className="py-3 px-4">Title & Message</th>
                    <th className="py-3 px-4">Target Class</th>
                    <th className="py-3 px-4">Date Sent</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {announcements.map((a, idx) => (
                    <tr key={a.id} className={idx === 0 ? 'bg-emerald-50/30' : 'hover:bg-slate-50/60'}>
                      <td className="py-3.5 px-4 font-bold">
                        {idx === 0 ? (
                          <span className="inline-flex items-center space-x-1 px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-bold">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span>
                            <span>ACTIVE ON HOME BANNER</span>
                          </span>
                        ) : (
                          <span className="text-slate-400 font-medium">Archived Notice</span>
                        )}
                      </td>
                      <td className="py-3.5 px-4">
                        <span className="px-2 py-1 rounded bg-slate-100 text-slate-700 font-bold text-[11px]">
                          {a.action_label || 'Curriculum'}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 max-w-md">
                        <p className="font-bold text-slate-900 text-xs">{a.title}</p>
                        <p className="text-slate-500 text-[11px] line-clamp-2 mt-0.5 leading-normal">
                          {a.message}
                        </p>
                      </td>
                      <td className="py-3.5 px-4 font-semibold text-slate-700">
                        {a.related_class ? `Class ${a.related_class}` : 'All Grades'}
                      </td>
                      <td className="py-3.5 px-4 text-slate-500 font-mono text-[11px]">
                        {new Date(a.created_at).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <button
                          onClick={() => handleDelete(a.id)}
                          disabled={deletingId === a.id}
                          className="px-2.5 py-1.5 rounded-lg text-rose-600 hover:bg-rose-50 border border-transparent hover:border-rose-200 transition font-semibold text-[11px] inline-flex items-center space-x-1 disabled:opacity-50"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                          <span>Delete</span>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
