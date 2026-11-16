import React from 'react';
import { redirect } from 'next/navigation';
import { getCurrentAdmin } from '@/lib/auth';
import { Sidebar } from '@/components/layout/Sidebar';
import { InactivityWatcher } from '@/components/layout/InactivityWatcher';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const admin = await getCurrentAdmin();
  if (!admin) {
    redirect('/login');
  }

  return (
    <div className="min-h-screen bg-slate-50 flex">
      {/* 5-Minute Inactivity Auto-Logout Watcher (Resets on cursor/keyboard activity) */}
      <InactivityWatcher timeoutSeconds={300} />

      {/* Sidebar */}
      <Sidebar
        adminName={admin.full_name}
        adminEmail={admin.email}
        adminRole={admin.role}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <main className="flex-1 p-6 md:p-8 max-w-7xl w-full mx-auto space-y-6">
          {children}
        </main>
      </div>
    </div>
  );
}

