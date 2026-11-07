'use client';

import React from 'react';
import { X, User, Mail, Phone, School, MapPin, Calendar, Clock, Shield, CheckCircle, Smartphone } from 'lucide-react';
import { formatDate } from '@/lib/utils';

export interface UserDetail {
  id: string;
  full_name: string;
  email: string;
  phone_number?: string;
  student_class?: string;
  school?: string;
  district?: string;
  role: string;
  status: string;
  created_at: string;
  last_login_at?: string;
  auth_provider?: string;
}

interface UserDetailsModalProps {
  user: UserDetail | null;
  onClose: () => void;
}

export function UserDetailsModal({ user, onClose }: UserDetailsModalProps) {
  if (!user) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="bg-white rounded-2xl shadow-2xl border border-slate-200 w-full max-w-xl overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 bg-gradient-to-r from-blue-900 to-indigo-900 text-white flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-12 h-12 rounded-full bg-white/10 border border-white/20 flex items-center justify-center text-xl font-bold">
              {user.full_name?.charAt(0) || 'S'}
            </div>
            <div>
              <h3 className="text-base font-bold leading-tight">{user.full_name}</h3>
              <p className="text-xs text-blue-200 font-mono mt-0.5 truncate max-w-[280px]">ID: {user.id}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-white/80 hover:text-white hover:bg-white/10 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="p-6 space-y-5 max-h-[75vh] overflow-y-auto">
          {/* Status and Role badges */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200">
            <div className="flex items-center space-x-2">
              <span className="text-xs text-slate-500 font-medium">Account Status:</span>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 border border-emerald-300">
                {user.status || 'Active'}
              </span>
            </div>
            <div className="flex items-center space-x-2">
              <span className="text-xs text-slate-500 font-medium">Platform Role:</span>
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-blue-100 text-blue-800 border border-blue-300">
                {user.role || 'Student'}
              </span>
            </div>
          </div>

          {/* Academic & Location details */}
          <div>
            <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
              Academic & Demographic Information
            </h4>
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 rounded-lg border border-slate-200/80 bg-white">
                <span className="text-[11px] text-slate-400 flex items-center space-x-1 mb-1">
                  <School className="w-3.5 h-3.5 text-blue-600" />
                  <span>Class / Grade</span>
                </span>
                <p className="text-sm font-bold text-slate-900">{user.student_class || 'Class 9'}</p>
              </div>

              <div className="p-3 rounded-lg border border-slate-200/80 bg-white">
                <span className="text-[11px] text-slate-400 flex items-center space-x-1 mb-1">
                  <MapPin className="w-3.5 h-3.5 text-blue-600" />
                  <span>District (KPK)</span>
                </span>
                <p className="text-sm font-bold text-slate-900">{user.district || 'Peshawar'}</p>
              </div>

              <div className="p-3 rounded-lg border border-slate-200/80 bg-white col-span-2">
                <span className="text-[11px] text-slate-400 flex items-center space-x-1 mb-1">
                  <School className="w-3.5 h-3.5 text-blue-600" />
                  <span>Institute / School</span>
                </span>
                <p className="text-sm font-bold text-slate-900">{user.school || 'Government High School Peshawar'}</p>
              </div>
            </div>
          </div>

          {/* Contact Details */}
          <div>
            <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
              Contact & Authentication
            </h4>
            <div className="space-y-2">
              <div className="flex items-center justify-between p-3 rounded-lg border border-slate-200/80 text-xs">
                <div className="flex items-center space-x-2 text-slate-600">
                  <Mail className="w-4 h-4 text-slate-400" />
                  <span className="font-medium">Email Address:</span>
                </div>
                <span className="font-semibold text-slate-900">{user.email}</span>
              </div>

              <div className="flex items-center justify-between p-3 rounded-lg border border-slate-200/80 text-xs">
                <div className="flex items-center space-x-2 text-slate-600">
                  <Phone className="w-4 h-4 text-slate-400" />
                  <span className="font-medium">Phone Number:</span>
                </div>
                <span className="font-semibold text-slate-900">{user.phone_number || 'Not provided'}</span>
              </div>

              <div className="flex items-center justify-between p-3 rounded-lg border border-slate-200/80 text-xs">
                <div className="flex items-center space-x-2 text-slate-600">
                  <Smartphone className="w-4 h-4 text-slate-400" />
                  <span className="font-medium">Auth Provider:</span>
                </div>
                <span className="font-mono text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                  {user.auth_provider || 'Supabase Auth'}
                </span>
              </div>
            </div>
          </div>

          {/* Audit Timestamps */}
          <div>
            <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">
              Timeline & Security Audit
            </h4>
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
                <span className="text-[11px] text-slate-500 flex items-center space-x-1 mb-1">
                  <Calendar className="w-3.5 h-3.5 text-slate-400" />
                  <span>Registration Date</span>
                </span>
                <p className="font-semibold text-slate-800">{formatDate(user.created_at)}</p>
              </div>

              <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
                <span className="text-[11px] text-slate-500 flex items-center space-x-1 mb-1">
                  <Clock className="w-3.5 h-3.5 text-slate-400" />
                  <span>Last Active / Login</span>
                </span>
                <p className="font-semibold text-slate-800">{formatDate(user.last_login_at)}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-3 bg-slate-50 border-t border-slate-200 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-lg bg-slate-800 text-white text-xs font-semibold hover:bg-slate-900 transition-colors"
          >
            Close Details
          </button>
        </div>
      </div>
    </div>
  );
}
