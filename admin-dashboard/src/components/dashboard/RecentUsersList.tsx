import React from 'react';
import Link from 'next/link';
import { UserCheck, ArrowRight } from 'lucide-react';
import { formatTimeAgo } from '@/lib/utils';

interface UserItem {
  id: string;
  full_name: string;
  email: string;
  student_class: string;
  district: string;
  status: string;
  created_at: string;
}

interface RecentUsersListProps {
  users: UserItem[];
}

export function RecentUsersList({ users }: RecentUsersListProps) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-bold text-slate-900 tracking-tight">Recent Registrations</h3>
          <p className="text-xs text-slate-500">Newly joined students from Flutter app</p>
        </div>
        <Link
          href="/users"
          className="text-xs font-semibold text-blue-600 hover:text-blue-800 flex items-center space-x-1"
        >
          <span>View All</span>
          <ArrowRight className="w-3.5 h-3.5" />
        </Link>
      </div>

      <div className="divide-y divide-slate-100">
        {users.length === 0 ? (
          <p className="text-xs text-slate-400 py-6 text-center">No students registered yet.</p>
        ) : (
          users.map((u) => (
            <div key={u.id} className="py-3 flex items-center justify-between hover:bg-slate-50/80 px-2 rounded-lg transition-colors">
              <div className="flex items-center space-x-3 min-w-0">
                <div className="w-8 h-8 rounded-full bg-blue-100 border border-blue-200 text-blue-700 flex items-center justify-center font-bold text-xs shrink-0">
                  {u.full_name?.charAt(0) || 'S'}
                </div>
                <div className="min-w-0">
                  <p className="text-xs font-bold text-slate-900 truncate">{u.full_name}</p>
                  <p className="text-[11px] text-slate-400 truncate">{u.email}</p>
                </div>
              </div>

              <div className="flex items-center space-x-3 shrink-0 text-right">
                <div>
                  <span className="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                    {u.student_class || 'Class 9'}
                  </span>
                  <p className="text-[10px] text-slate-400 mt-0.5">{formatTimeAgo(u.created_at)}</p>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
