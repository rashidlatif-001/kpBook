'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useSearchParams } from 'next/navigation';
import {
  Search,
  Filter,
  Download,
  ChevronLeft,
  ChevronRight,
  Eye,
  ArrowUpDown,
  RefreshCw,
  UserCheck,
  Calendar,
  X,
} from 'lucide-react';
import { formatDate } from '@/lib/utils';
import { UserDetailsModal, UserDetail } from './UserDetailsModal';

const DISTRICTS = [
  'All Districts',
  'Peshawar',
  'Mardan',
  'Swat',
  'Abbottabad',
  'Kohat',
  'Bannu',
  'Dera Ismail Khan',
  'Charsadda',
  'Nowshera',
  'Swabi',
  'Haripur',
  'Mansehra',
  'Malakand',
  'Dir Lower',
  'Dir Upper',
];

const CLASSES = [
  'All Classes',
  'Class 1',
  'Class 2',
  'Class 3',
  'Class 4',
  'Class 5',
  'Class 6',
  'Class 7',
  'Class 8',
  'Class 9',
  'Class 10',
  'Class 11',
  'Class 12',
];

export function UserTable() {
  const searchParams = useSearchParams();
  const urlClass = searchParams.get('class') || 'All Classes';
  const urlStatus = searchParams.get('status') || 'All Statuses';
  const urlTimeframe = searchParams.get('timeframe') || '';

  const [users, setUsers] = useState<UserDetail[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedClass, setSelectedClass] = useState(urlClass);
  const [selectedDistrict, setSelectedDistrict] = useState('All Districts');
  const [selectedStatus, setSelectedStatus] = useState(urlStatus);
  const [timeframe, setTimeframe] = useState(urlTimeframe);
  const [sortBy, setSortBy] = useState('created_at');
  const [order, setOrder] = useState<'asc' | 'desc'>('desc');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const [selectedUser, setSelectedUser] = useState<UserDetail | null>(null);
  const [exporting, setExporting] = useState(false);

  // Sync state if URL changes
  useEffect(() => {
    if (urlClass !== 'All Classes') setSelectedClass(urlClass);
    if (urlStatus !== 'All Statuses') setSelectedStatus(urlStatus);
    if (urlTimeframe) setTimeframe(urlTimeframe);
  }, [urlClass, urlStatus, urlTimeframe]);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (search.trim()) params.set('search', search.trim());
      if (selectedClass !== 'All Classes') params.set('class', selectedClass);
      if (selectedDistrict !== 'All Districts') params.set('district', selectedDistrict);
      if (selectedStatus !== 'All Statuses') params.set('status', selectedStatus.toLowerCase());
      if (timeframe) params.set('timeframe', timeframe);
      params.set('sort_by', sortBy);
      params.set('order', order);
      params.set('page', page.toString());
      params.set('limit', '10');

      const res = await fetch(`/api/users?${params.toString()}`);
      if (!res.ok) throw new Error('Failed to load users');
      const data = await res.json();
      setUsers(data.users || []);
      setTotalPages(data.pagination?.totalPages || 1);
      setTotalUsers(data.pagination?.total || 0);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [search, selectedClass, selectedDistrict, selectedStatus, timeframe, sortBy, order, page]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const handleExportCsv = async () => {
    setExporting(true);
    try {
      window.location.href = '/api/users/export';
    } finally {
      setTimeout(() => setExporting(false), 1500);
    }
  };

  const toggleSort = (col: string) => {
    if (sortBy === col) {
      setOrder(order === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(col);
      setOrder('desc');
    }
  };

  return (
    <div className="space-y-4">
      {/* Controls Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-xs space-y-3">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
          {/* Search box */}
          <div className="relative flex-1 max-w-md">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              placeholder="Search by student name, email, phone, school, or district..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="w-full pl-9 pr-4 py-2 rounded-lg border border-slate-200 text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-600 focus:border-transparent bg-slate-50/50"
            />
          </div>

          {/* Action buttons */}
          <div className="flex items-center space-x-2">
            <button
              onClick={() => fetchUsers()}
              className="p-2 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors"
              title="Refresh"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin text-blue-600' : ''}`} />
            </button>

            <button
              onClick={handleExportCsv}
              disabled={exporting}
              className="flex items-center space-x-1.5 px-3.5 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-xs transition-colors"
            >
              <Download className="w-4 h-4" />
              <span>{exporting ? 'Exporting...' : 'Export CSV'}</span>
            </button>
          </div>
        </div>

        {/* Filters Row */}
        <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-slate-100 text-xs">
          <span className="text-slate-400 font-semibold flex items-center space-x-1 mr-1">
            <Filter className="w-3.5 h-3.5" />
            <span>Filters:</span>
          </span>

          {/* Class Filter */}
          <select
            value={selectedClass}
            onChange={(e) => {
              setSelectedClass(e.target.value);
              setPage(1);
            }}
            className="px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white text-slate-700 font-medium text-xs focus:ring-2 focus:ring-blue-500"
          >
            {CLASSES.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>

          {/* District Filter */}
          <select
            value={selectedDistrict}
            onChange={(e) => {
              setSelectedDistrict(e.target.value);
              setPage(1);
            }}
            className="px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white text-slate-700 font-medium text-xs focus:ring-2 focus:ring-blue-500"
          >
            {DISTRICTS.map((d) => (
              <option key={d} value={d}>{d}</option>
            ))}
          </select>

          {/* Status Filter */}
          <select
            value={selectedStatus}
            onChange={(e) => {
              setSelectedStatus(e.target.value);
              setPage(1);
            }}
            className="px-2.5 py-1.5 rounded-lg border border-slate-200 bg-white text-slate-700 font-medium text-xs focus:ring-2 focus:ring-blue-500"
          >
            <option value="All Statuses">All Statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="suspended">Suspended</option>
          </select>

          {/* Timeframe Pill */}
          {timeframe && (
            <span className="inline-flex items-center space-x-1.5 px-2.5 py-1 rounded-full bg-blue-100 text-blue-800 font-bold text-xs border border-blue-300">
              <Calendar className="w-3 h-3 text-blue-700" />
              <span>{timeframe === 'today' ? "Today's Signups" : timeframe === 'weekly' ? "Past 7 Days Signups" : timeframe}</span>
              <button
                onClick={() => {
                  setTimeframe('');
                  setPage(1);
                }}
                className="hover:text-rose-600 ml-1 p-0.5 rounded-full hover:bg-blue-200"
                title="Remove timeframe filter"
              >
                <X className="w-3 h-3" />
              </button>
            </span>
          )}

          {/* Reset Filters */}
          {(selectedClass !== 'All Classes' || selectedDistrict !== 'All Districts' || selectedStatus !== 'All Statuses' || timeframe || search) && (
            <button
              onClick={() => {
                setSelectedClass('All Classes');
                setSelectedDistrict('All Districts');
                setSelectedStatus('All Statuses');
                setTimeframe('');
                setSearch('');
                setPage(1);
              }}
              className="text-xs text-blue-600 hover:underline font-semibold ml-auto"
            >
              Reset Filters
            </button>
          )}
        </div>
      </div>

      {/* Main Table Card */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-50 text-slate-600 uppercase tracking-wider text-[11px] font-bold border-b border-slate-200">
              <tr>
                <th
                  onClick={() => toggleSort('full_name')}
                  className="py-3 px-4 cursor-pointer hover:bg-slate-100/80 transition-colors"
                >
                  <div className="flex items-center space-x-1">
                    <span>Student / Name</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-400" />
                  </div>
                </th>
                <th className="py-3 px-4">Contact</th>
                <th
                  onClick={() => toggleSort('student_class')}
                  className="py-3 px-4 cursor-pointer hover:bg-slate-100/80 transition-colors"
                >
                  <div className="flex items-center space-x-1">
                    <span>Class</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-400" />
                  </div>
                </th>
                <th className="py-3 px-4">District & School</th>
                <th
                  onClick={() => toggleSort('created_at')}
                  className="py-3 px-4 cursor-pointer hover:bg-slate-100/80 transition-colors"
                >
                  <div className="flex items-center space-x-1">
                    <span>Joined Date</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-400" />
                  </div>
                </th>
                <th
                  onClick={() => toggleSort('last_login_at')}
                  className="py-3 px-4 cursor-pointer hover:bg-slate-100/80 transition-colors"
                >
                  <div className="flex items-center space-x-1">
                    <span>Last Login</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-400" />
                  </div>
                </th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100 text-slate-700">
              {loading ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    <div className="flex items-center justify-center space-x-2">
                      <RefreshCw className="w-4 h-4 animate-spin text-blue-600" />
                      <span>Loading registered users from database...</span>
                    </div>
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-400">
                    No registered students found matching your filters.
                  </td>
                </tr>
              ) : (
                users.map((u) => (
                  <tr key={u.id} className="hover:bg-slate-50/80 transition-colors">
                    {/* Name & ID */}
                    <td className="py-3 px-4">
                      <div className="flex items-center space-x-3">
                        <div className="w-8 h-8 rounded-full bg-blue-100 border border-blue-200 text-blue-800 flex items-center justify-center font-bold text-xs shrink-0">
                          {u.full_name?.charAt(0) || 'S'}
                        </div>
                        <div className="min-w-0">
                          <p className="font-bold text-slate-900 truncate">{u.full_name}</p>
                          <p className="text-[10px] text-slate-400 font-mono truncate max-w-[140px]" title={u.id}>
                            UID: {u.id}
                          </p>
                        </div>
                      </div>
                    </td>

                    {/* Contact */}
                    <td className="py-3 px-4">
                      <p className="font-medium text-slate-900">{u.email}</p>
                      <p className="text-[11px] text-slate-400">{u.phone_number || 'No phone'}</p>
                    </td>

                    {/* Class */}
                    <td className="py-3 px-4">
                      <span className="inline-block px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-blue-50 text-blue-700 border border-blue-200/60">
                        {u.student_class || 'Class 9'}
                      </span>
                    </td>

                    {/* District & School */}
                    <td className="py-3 px-4">
                      <p className="font-semibold text-slate-800">{u.district || 'Peshawar'}</p>
                      <p className="text-[11px] text-slate-400 truncate max-w-[180px]">
                        {u.school || 'Govt High School'}
                      </p>
                    </td>

                    {/* Registration Date */}
                    <td className="py-3 px-4 text-slate-600 font-medium">
                      {formatDate(u.created_at)}
                    </td>

                    {/* Last Login */}
                    <td className="py-3 px-4 text-slate-600 font-medium">
                      {formatDate(u.last_login_at)}
                    </td>

                    {/* Status */}
                    <td className="py-3 px-4">
                      <span className="inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        {u.status || 'Active'}
                      </span>
                    </td>

                    {/* Actions */}
                    <td className="py-3 px-4 text-right">
                      <button
                        onClick={() => setSelectedUser(u)}
                        className="inline-flex items-center space-x-1 px-2.5 py-1.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-200 transition-colors text-xs font-semibold"
                        title="View Full Profile"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>Details</span>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        <div className="px-4 py-3 bg-slate-50 border-t border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-600">
          <div>
            Showing <span className="font-bold">{users.length}</span> of <span className="font-bold">{totalUsers}</span> registered students
          </div>

          <div className="flex items-center space-x-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page <= 1}
              className="p-1.5 rounded-lg border border-slate-200 bg-white text-slate-600 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-100"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="font-semibold px-2">
              Page {page} of {totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page >= totalPages}
              className="p-1.5 rounded-lg border border-slate-200 bg-white text-slate-600 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-100"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Profile Details Modal */}
      <UserDetailsModal
        user={selectedUser}
        onClose={() => setSelectedUser(null)}
      />
    </div>
  );
}

