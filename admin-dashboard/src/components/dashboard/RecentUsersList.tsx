'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { ArrowRight, Eye, UserCheck } from 'lucide-react';
import { formatTimeAgo } from '@/lib/utils';
import { UserDetailsModal, UserDetail } from '../users/UserDetailsModal';

interface UserItem {
  id: string;
  full_name: string;
  email: string;
  phone_number?: string;
  student_class: string;
  district: string;
  school?: string;
  role?: string;
  status: string;
  created_at: string;
  last_login_at?: string;
  auth_provider?: string;
}

interface RecentUsersListProps {
  users: UserItem[];
}

export function RecentUsersList({ users }: RecentUsersListProps) {
  const [selectedUser, setSelectedUser] = useState<UserDetail | null>(null);

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5 shadow-xs flex flex-col justify-between h-full">
      <div>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-sm font-bold text-slate-900 tracking-tight">Recent Registrations</h3>
            <p className="text-xs text-slate-500">Click any student to inspect full profile</p>
          </div>
          <Link
            href="/users"
            className="text-xs font-semibold text-blue-600 hover:text-blue-800 flex items-center space-x-1 hover:underline"
          >
            <span>View All</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        <div className="divide-y divide-slate-100">
          {users.length === 0 ? (
            <div className="py-10 text-center space-y-2">
              <div className="w-10 h-10 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
                <UserCheck className="w-5 h-5" />
              </div>
              <p className="text-xs font-semibold text-slate-600">No registered students yet</p>
              <p className="text-[11px] text-slate-400 max-w-[200px] mx-auto">
                When students register in the KPK Books mobile app, they will appear here live.
              </p>
            </div>
          ) : (
            users.map((u) => (
              <div
                key={u.id}
                onClick={() =>
                  setSelectedUser({
                    id: u.id,
                    full_name: u.full_name,
                    email: u.email,
                    phone_number: u.phone_number,
                    student_class: u.student_class,
                    school: u.school,
                    district: u.district,
                    role: u.role || 'student',
                    status: u.status,
                    created_at: u.created_at,
                    last_login_at: u.last_login_at,
                    auth_provider: u.auth_provider,
                  })
                }
                className="py-3 flex items-center justify-between hover:bg-blue-50/60 px-2 rounded-lg transition-colors cursor-pointer group"
                title="Click to view details"
              >
                <div className="flex items-center space-x-3 min-w-0">
                  <div className="w-8 h-8 rounded-full bg-blue-100 border border-blue-200 text-blue-700 flex items-center justify-center font-bold text-xs shrink-0 group-hover:bg-blue-600 group-hover:text-white transition-colors">
                    {u.full_name?.charAt(0) || 'S'}
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-bold text-slate-900 group-hover:text-blue-700 transition-colors truncate">
                      {u.full_name}
                    </p>
                    <p className="text-[11px] text-slate-400 truncate">{u.email}</p>
                  </div>
                </div>

                <div className="flex items-center space-x-2 shrink-0 text-right">
                  <span className="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200 group-hover:border-blue-200">
                    {u.student_class || 'Class 9'}
                  </span>
                  <Eye className="w-3.5 h-3.5 text-slate-400 group-hover:text-blue-600 transition-colors" />
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      <div className="mt-4 pt-3 border-t border-slate-100 text-center">
        <Link
          href="/users"
          className="text-xs font-bold text-blue-600 hover:text-blue-800 hover:underline"
        >
          Open Complete Student Directory &rarr;
        </Link>
      </div>

      {/* Details Modal */}
      <UserDetailsModal
        user={selectedUser}
        onClose={() => setSelectedUser(null)}
      />
    </div>
  );
}
