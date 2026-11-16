'use client';

import React, { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import {
  BookOpen,
  ArrowLeft,
  CheckCircle2,
  Edit3,
  Save,
  X,
  Layers,
  FileText,
  Sigma,
  Table,
  Image as ImageIcon,
  HelpCircle,
  AlertCircle,
  Eye,
  Check,
  Smartphone,
  ExternalLink,
} from 'lucide-react';

interface ContentBlock {
  id: string;
  topic_id: string;
  block_type: string;
  content: string;
  display_order: number;
  original_pdf_page: number;
  metadata: any;
}

interface Topic {
  id: string;
  chapter_id: string;
  topic_number: string;
  title: string;
  title_urdu: string;
  start_page: number;
  end_page: number;
  display_order: number;
  content_blocks: ContentBlock[];
}

interface Chapter {
  id: string;
  chapter_number: number;
  title: string;
  title_urdu: string;
  start_page: number;
  end_page: number;
  slo_summary?: string;
  key_topics?: string[];
  topics: Topic[];
}

interface BookDetails {
  id: string;
  title: string;
  title_urdu: string;
  class_number: number;
  subject_name: string;
  board_name: string;
  edition: string;
  total_pages: number;
  publication_status: 'draft' | 'reviewing' | 'published';
}

export default function TextbookPreviewPage() {
  const params = useParams();
  const router = useRouter();
  const bookId = params.id as string;

  const [book, setBook] = useState<BookDetails | null>(null);
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [selectedChapterIdx, setSelectedChapterIdx] = useState(0);
  const [selectedTopicIdx, setSelectedTopicIdx] = useState(0);
  const [loading, setLoading] = useState(true);

  // Editing content block state
  const [editingBlockId, setEditingBlockId] = useState<string | null>(null);
  const [editContent, setEditContent] = useState('');
  const [editPage, setEditPage] = useState<number>(1);
  const [editType, setEditType] = useState('paragraph');
  const [saving, setSaving] = useState(false);

  // Publishing state
  const [publishing, setPublishing] = useState(false);
  const [publishSuccess, setPublishSuccess] = useState(false);

  const fetchPreviewData = async () => {
    setLoading(true);
    try {
      const res = await fetch(`/api/textbooks/${bookId}/preview`);
      const data = await res.json();
      if (data.book) {
        setBook(data.book);
        setChapters(data.chapters || []);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (bookId) fetchPreviewData();
  }, [bookId]);

  const handleStartEdit = (block: ContentBlock) => {
    setEditingBlockId(block.id);
    setEditContent(block.content);
    setEditPage(block.original_pdf_page);
    setEditType(block.block_type);
  };

  const handleSaveBlock = async () => {
    if (!editingBlockId) return;
    setSaving(true);
    try {
      const res = await fetch(`/api/textbooks/${bookId}/preview`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          block_id: editingBlockId,
          content: editContent,
          block_type: editType,
          original_pdf_page: editPage,
        }),
      });

      if (res.ok) {
        // Update local state
        setChapters((prev) =>
          prev.map((ch, cIdx) => {
            if (cIdx !== selectedChapterIdx) return ch;
            return {
              ...ch,
              topics: ch.topics.map((top, tIdx) => {
                if (tIdx !== selectedTopicIdx) return top;
                return {
                  ...top,
                  content_blocks: top.content_blocks.map((blk) =>
                    blk.id === editingBlockId
                      ? { ...blk, content: editContent, block_type: editType, original_pdf_page: editPage }
                      : blk
                  ),
                };
              }),
            };
          })
        );
        setEditingBlockId(null);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handlePublish = async () => {
    if (!book) return;
    setPublishing(true);
    try {
      const res = await fetch(`/api/textbooks/${book.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ publication_status: 'published' }),
      });
      if (res.ok) {
        setBook({ ...book, publication_status: 'published' });
        setPublishSuccess(true);
        setTimeout(() => setPublishSuccess(false), 4000);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setPublishing(false);
    }
  };

  if (loading) {
    return (
      <div className="py-24 text-center">
        <div className="inline-block w-8 h-8 border-3 border-blue-500 border-t-transparent rounded-full animate-spin mb-3"></div>
        <p className="text-slate-400 font-medium text-sm">Loading structured textbook preview...</p>
      </div>
    );
  }

  if (!book) {
    return (
      <div className="py-24 text-center">
        <AlertCircle className="w-10 h-10 text-rose-400 mx-auto mb-2" />
        <p className="text-white font-bold">Textbook not found</p>
        <Link href="/textbooks" className="text-sm text-blue-400 hover:underline mt-2 inline-block">
          Return to Library
        </Link>
      </div>
    );
  }

  const activeChapter = chapters[selectedChapterIdx];
  const activeTopic = activeChapter?.topics?.[selectedTopicIdx];
  const contentBlocks = activeTopic?.content_blocks || [];

  return (
    <div className="space-y-6">
      {/* Top Bar with Navigation & Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <Link
            href="/textbooks"
            className="inline-flex items-center space-x-1.5 text-xs font-medium text-slate-400 hover:text-white transition-colors mb-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back to Textbook Library</span>
          </Link>
          <div className="flex items-center space-x-3">
            <span className="px-2.5 py-0.5 rounded text-xs font-bold bg-blue-500/20 text-blue-300 border border-blue-400/30">
              Class {book.class_number}
            </span>
            <h1 className="text-2xl font-bold text-white tracking-tight">{book.title}</h1>
            <span
              className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                book.publication_status === 'published'
                  ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                  : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
              }`}
            >
              {book.publication_status === 'published' ? 'Live on Mobile App' : 'Draft / Staging'}
            </span>
          </div>
        </div>

        {/* Publish Action Button */}
        <div className="flex items-center space-x-3 shrink-0">
          {publishSuccess && (
            <span className="flex items-center space-x-1 text-emerald-400 text-xs font-medium bg-emerald-950/60 px-3 py-1.5 rounded-lg border border-emerald-800/80">
              <Check className="w-4 h-4" />
              <span>Published to Mobile App!</span>
            </span>
          )}

          <button
            onClick={handlePublish}
            disabled={publishing || book.publication_status === 'published'}
            className={`inline-flex items-center space-x-2 px-5 py-2.5 rounded-xl font-medium text-sm transition-all shadow-md ${
              book.publication_status === 'published'
                ? 'bg-slate-800 text-slate-400 border border-slate-700 cursor-default'
                : 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-emerald-600/20'
            }`}
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>{book.publication_status === 'published' ? 'Approved & Published' : 'Approve & Publish to Mobile'}</span>
          </button>
        </div>
      </div>

      {/* Main Workspace Layout (Sidebar Chapter Nav + Central Interactive Content Canvas) */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 items-start">
        {/* Left Column: Chapters & Topics Tree */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-4 space-y-4 shadow-sm">
          <div className="flex items-center justify-between pb-3 border-b border-slate-800">
            <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">
              Curriculum Units ({chapters.length})
            </span>
          </div>

          <div className="space-y-2 max-h-[600px] overflow-y-auto pr-1">
            {chapters.map((ch, cIdx) => {
              const isSelected = cIdx === selectedChapterIdx;
              return (
                <div key={ch.id} className="space-y-1">
                  <button
                    onClick={() => {
                      setSelectedChapterIdx(cIdx);
                      setSelectedTopicIdx(0);
                    }}
                    className={`w-full text-left px-3 py-2 rounded-xl text-xs font-medium transition-colors flex items-center justify-between ${
                      isSelected
                        ? 'bg-blue-600 text-white shadow-sm'
                        : 'text-slate-300 hover:bg-slate-800/80'
                    }`}
                  >
                    <div className="flex items-center space-x-2 truncate">
                      <span className="font-bold">Unit {ch.chapter_number}:</span>
                      <span className="truncate">{ch.title}</span>
                    </div>
                    <span className="text-[10px] opacity-75 shrink-0 ml-1">
                      Pg {ch.start_page}–{ch.end_page}
                    </span>
                  </button>

                  {/* Subtopics under selected chapter */}
                  {isSelected && ch.topics && ch.topics.length > 0 && (
                    <div className="pl-4 space-y-1 mt-1 border-l-2 border-slate-700 ml-3">
                      {ch.topics.map((top, tIdx) => {
                        const isTopicSelected = tIdx === selectedTopicIdx;
                        return (
                          <button
                            key={top.id}
                            onClick={() => setSelectedTopicIdx(tIdx)}
                            className={`w-full text-left px-2.5 py-1.5 rounded-lg text-[11px] transition-colors truncate block ${
                              isTopicSelected
                                ? 'bg-amber-500/20 text-amber-300 font-semibold border border-amber-500/30'
                                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
                            }`}
                          >
                            {top.topic_number} {top.title}
                          </button>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Right Column: Interactive Content Viewer & Editor Canvas */}
        <div className="lg:col-span-3 space-y-4">
          {/* Active Unit / Topic Header Banner */}
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-sm">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
              <div>
                <p className="text-xs font-bold text-emerald-400 uppercase tracking-wider">
                  Unit {activeChapter?.chapter_number} • Section {activeTopic?.topic_number}
                </p>
                <h2 className="text-xl font-bold text-white mt-0.5">{activeTopic?.title || activeChapter?.title}</h2>
              </div>
              <div className="flex items-center space-x-2 text-xs text-slate-400 bg-slate-950 px-3 py-1.5 rounded-lg border border-slate-800">
                <Smartphone className="w-3.5 h-3.5 text-blue-400" />
                <span>Original PDF Page: {activeTopic?.start_page || activeChapter?.start_page}</span>
              </div>
            </div>

            {/* SLO Banner if present */}
            {activeChapter?.slo_summary && (
              <div className="mt-4 p-3.5 rounded-xl bg-emerald-950/30 border-l-4 border-emerald-500 text-xs text-emerald-300">
                <span className="font-bold tracking-wide uppercase block text-[10px] text-emerald-400 mb-1">
                  Student Learning Objectives (SLO)
                </span>
                <p className="leading-relaxed">{activeChapter.slo_summary}</p>
              </div>
            )}
          </div>

          {/* Extracted Content Blocks List */}
          <div className="space-y-3">
            {contentBlocks.length === 0 ? (
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-12 text-center text-slate-400">
                <FileText className="w-8 h-8 text-slate-500 mx-auto mb-2" />
                <p className="font-semibold text-white">No content blocks found for this section</p>
                <p className="text-xs text-slate-500 mt-1">Select another topic from the sidebar.</p>
              </div>
            ) : (
              contentBlocks.map((blk) => {
                const isEditing = editingBlockId === blk.id;

                return (
                  <div
                    key={blk.id}
                    className="bg-slate-900 border border-slate-800 rounded-xl p-4 shadow-sm hover:border-slate-700 transition-colors group relative"
                  >
                    {/* Block Type Badge and Page reference */}
                    <div className="flex items-center justify-between mb-2 pb-2 border-b border-slate-800/60">
                      <div className="flex items-center space-x-2">
                        <span
                          className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${
                            blk.block_type === 'heading'
                              ? 'bg-blue-500/20 text-blue-300'
                              : blk.block_type === 'formula'
                              ? 'bg-purple-500/20 text-purple-300'
                              : blk.block_type === 'definition'
                              ? 'bg-amber-500/20 text-amber-300'
                              : blk.block_type === 'table'
                              ? 'bg-cyan-500/20 text-cyan-300'
                              : 'bg-slate-800 text-slate-400'
                          }`}
                        >
                          {blk.block_type}
                        </span>
                        <span className="text-[11px] text-slate-500">PDF Page {blk.original_pdf_page}</span>
                      </div>

                      {/* Edit Trigger */}
                      {!isEditing && (
                        <button
                          onClick={() => handleStartEdit(blk)}
                          className="opacity-0 group-hover:opacity-100 flex items-center space-x-1 text-xs text-blue-400 hover:text-blue-300 transition-opacity bg-slate-800 px-2.5 py-1 rounded-lg"
                        >
                          <Edit3 className="w-3 h-3" />
                          <span>Edit</span>
                        </button>
                      )}
                    </div>

                    {/* Block Content Render / Inline Editor */}
                    {isEditing ? (
                      <div className="space-y-3 mt-2">
                        <div className="flex items-center space-x-3">
                          <select
                            value={editType}
                            onChange={(e) => setEditType(e.target.value)}
                            className="bg-slate-950 border border-slate-700 text-xs text-slate-200 rounded px-2.5 py-1"
                          >
                            <option value="paragraph">Paragraph</option>
                            <option value="heading">Heading</option>
                            <option value="formula">Formula (LaTeX)</option>
                            <option value="definition">Definition</option>
                            <option value="important_note">Important Note / SLO</option>
                            <option value="table">Table (Markdown)</option>
                            <option value="solved_example">Solved Example</option>
                          </select>

                          <div className="flex items-center space-x-1.5 text-xs text-slate-400">
                            <span>PDF Page:</span>
                            <input
                              type="number"
                              value={editPage}
                              onChange={(e) => setEditPage(parseInt(e.target.value, 10))}
                              className="w-16 bg-slate-950 border border-slate-700 text-xs text-slate-200 rounded px-2 py-1"
                            />
                          </div>
                        </div>

                        <textarea
                          rows={4}
                          value={editContent}
                          onChange={(e) => setEditContent(e.target.value)}
                          className="w-full bg-slate-950 border border-blue-500/80 rounded-lg p-3 text-sm text-slate-100 focus:outline-none font-mono"
                        />

                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => setEditingBlockId(null)}
                            disabled={saving}
                            className="px-3 py-1.5 rounded-lg bg-slate-800 text-slate-300 text-xs font-medium hover:bg-slate-700"
                          >
                            Cancel
                          </button>
                          <button
                            onClick={handleSaveBlock}
                            disabled={saving}
                            className="inline-flex items-center space-x-1.5 px-4 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-xs font-medium shadow"
                          >
                            <Save className="w-3.5 h-3.5" />
                            <span>{saving ? 'Saving...' : 'Save Block'}</span>
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div>
                        {blk.block_type === 'heading' && (
                          <h3 className="text-base font-bold text-white tracking-tight">{blk.content}</h3>
                        )}
                        {blk.block_type === 'formula' && (
                          <div className="p-3 my-1 rounded-lg bg-purple-950/30 border border-purple-800/40 font-mono text-purple-200 text-sm">
                            {blk.content}
                          </div>
                        )}
                        {blk.block_type === 'definition' && (
                          <div className="p-3 my-1 rounded-lg bg-amber-950/30 border-l-4 border-amber-500 text-amber-200 text-sm">
                            {blk.content}
                          </div>
                        )}
                        {blk.block_type === 'paragraph' && (
                          <p className="text-sm text-slate-300 leading-relaxed">{blk.content}</p>
                        )}
                        {blk.block_type === 'table' && (
                          <div className="overflow-x-auto p-2 bg-slate-950/60 rounded border border-slate-800 font-mono text-xs text-slate-300 whitespace-pre">
                            {blk.content}
                          </div>
                        )}
                        {blk.block_type !== 'heading' &&
                          blk.block_type !== 'formula' &&
                          blk.block_type !== 'definition' &&
                          blk.block_type !== 'paragraph' &&
                          blk.block_type !== 'table' && (
                            <p className="text-sm text-slate-300">{blk.content}</p>
                          )}
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
