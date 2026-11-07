import React from 'react';
import { getCurrentAdmin } from '@/lib/auth';
import { Topbar } from '@/components/layout/Topbar';
import { Database, Shield, Smartphone, Globe, CheckCircle2, Key, Server, Cpu } from 'lucide-react';

export default async function SettingsPage() {
  const admin = await getCurrentAdmin();

  return (
    <>
      <Topbar
        title="System Settings & Infrastructure Status"
        description="Verify database connections, API configurations, and admin credentials"
      />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Backend Infrastructure Card */}
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4">
          <div className="flex items-center space-x-3 mb-2">
            <div className="p-2.5 rounded-xl bg-blue-50 text-blue-700 border border-blue-200">
              <Database className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">Supabase Cloud Database</h3>
              <p className="text-xs text-slate-500">Primary database for KPK Books user profiles & activity</p>
            </div>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Project Reference:</span>
              <span className="font-mono font-semibold text-slate-900">tsqypxgfaajwqcgtfdkq</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Database Region:</span>
              <span className="font-semibold text-emerald-700 flex items-center space-x-1.5">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                <span>West EU (Ireland) - Nano</span>
              </span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">PostgreSQL Pooler Host:</span>
              <span className="font-mono text-slate-700">aws-0-eu-west-1.pooler.supabase.com:6543</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Automatic Trigger Status:</span>
              <span className="font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                ACTIVE (on_auth_user_created)
              </span>
            </div>
          </div>
        </div>

        {/* Firebase & Mobile Sync Card */}
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4">
          <div className="flex items-center space-x-3 mb-2">
            <div className="p-2.5 rounded-xl bg-amber-50 text-amber-700 border border-amber-200">
              <Smartphone className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">Firebase & Mobile App Sync</h3>
              <p className="text-xs text-slate-500">KPK Books Flutter mobile application integration</p>
            </div>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Firebase Project ID:</span>
              <span className="font-mono font-semibold text-slate-900">kpbooks-dbdcb</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Mobile Package Name:</span>
              <span className="font-mono text-slate-700">pk.gov.kp.textbook.kp_book</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Distribution Channel:</span>
              <span className="font-semibold text-blue-700">Firebase App Distribution & GitHub Actions</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Sync Ingestion Endpoint:</span>
              <span className="font-mono text-[11px] text-blue-700 bg-blue-50 px-2 py-0.5 rounded">
                /api/sync/flutter-event
              </span>
            </div>
          </div>
        </div>

        {/* Administrator Profile Card */}
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4">
          <div className="flex items-center space-x-3 mb-2">
            <div className="p-2.5 rounded-xl bg-emerald-50 text-emerald-700 border border-emerald-200">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">Administrator Access</h3>
              <p className="text-xs text-slate-500">Authenticated administrator profile & permissions</p>
            </div>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Full Name:</span>
              <span className="font-bold text-slate-900">{admin?.full_name}</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Official Email:</span>
              <span className="font-semibold text-slate-800">{admin?.email}</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Assigned Role:</span>
              <span className="font-extrabold text-blue-700 bg-blue-50 px-2 py-0.5 rounded border border-blue-200 uppercase">
                {admin?.role}
              </span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Session Type:</span>
              <span className="font-medium text-slate-700">Encrypted JWT HTTP-Only Cookie</span>
            </div>
          </div>
        </div>

        {/* Vercel Deployment Guidelines Card */}
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-xs space-y-4">
          <div className="flex items-center space-x-3 mb-2">
            <div className="p-2.5 rounded-xl bg-indigo-50 text-indigo-700 border border-indigo-200">
              <Globe className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">Vercel Production Deployment</h3>
              <p className="text-xs text-slate-500">Target production environment configuration</p>
            </div>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Target URL:</span>
              <span className="font-mono text-blue-700 font-semibold">https://kpk-books-admin.vercel.app</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Framework Preset:</span>
              <span className="font-bold text-slate-900">Next.js (App Router)</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Root Directory Setting:</span>
              <span className="font-mono bg-slate-200 px-2 py-0.5 rounded text-slate-800 font-bold">admin-dashboard</span>
            </div>

            <div className="flex justify-between items-center p-3 rounded-lg bg-slate-50 border border-slate-200">
              <span className="text-slate-600 font-medium">Build Command:</span>
              <span className="font-mono text-slate-700">npm run build</span>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

