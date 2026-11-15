import React from 'react';
import Link from 'next/link';
import { BookOpen, Shield, Lock, Eye, CheckCircle2, ArrowLeft } from 'lucide-react';

export const metadata = {
  title: 'Privacy Policy | KPK E-Textbooks (Pakhtunkhwa Ilm)',
  description: 'Official Privacy Policy for KPK E-Textbooks mobile application and services.',
};

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      {/* Official Header */}
      <header className="border-b border-slate-200 bg-white sticky top-0 z-30 shadow-xs">
        <div className="max-w-5xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-700 flex items-center justify-center text-white shadow-sm">
              <BookOpen className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-base font-bold text-slate-900 leading-tight">KPK E-Textbooks</h1>
              <p className="text-xs text-slate-500">Khyber Pakhtunkhwa Textbook Board • Government of KP</p>
            </div>
          </div>
          <Link
            href="/login"
            className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 flex items-center space-x-1 border border-emerald-200 bg-emerald-50 px-3 py-1.5 rounded-lg"
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span>Admin Portal</span>
          </Link>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 py-10">
        <div className="bg-white rounded-2xl border border-slate-200 p-8 sm:p-12 shadow-sm space-y-8">
          <div className="border-b border-slate-100 pb-6">
            <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold mb-3">
              <Shield className="w-3.5 h-3.5" />
              <span>Official Privacy Policy</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
              Privacy Policy for KPK E-Textbooks
            </h1>
            <p className="text-xs text-slate-500 mt-2">
              Last updated: November 15, 2026 • Effective for all users of the mobile application and services
            </p>
          </div>

          {/* Section 1 */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">1</span>
              <span>Introduction & Purpose</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              <strong>Pakhtunkhwa Ilm (KPK E-Textbooks)</strong> is the official educational mobile application developed for the Khyber Pakhtunkhwa Textbook Board (KPTBB), Elementary & Secondary Education Department, Government of Khyber Pakhtunkhwa. We are committed to protecting the privacy of students, teachers, and parents accessing educational textbooks, guides, and syllabus resources.
            </p>
          </section>

          {/* Section 2 */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">2</span>
              <span>Information We Collect</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              We collect minimal information necessary to deliver educational curriculum and personalize reading progress:
            </p>
            <div className="grid sm:grid-cols-2 gap-3 pt-2">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200/70">
                <h3 className="text-xs font-bold text-slate-900 uppercase tracking-wide mb-1 flex items-center space-x-1.5">
                  <Eye className="w-3.5 h-3.5 text-emerald-700" />
                  <span>Account & Profile Data</span>
                </h3>
                <p className="text-xs text-slate-600 leading-normal">
                  When you register via Email or Google Sign-In, we receive your name, email address, profile picture (if provided), and academic class/grade preference.
                </p>
              </div>
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200/70">
                <h3 className="text-xs font-bold text-slate-900 uppercase tracking-wide mb-1 flex items-center space-x-1.5">
                  <Lock className="w-3.5 h-3.5 text-emerald-700" />
                  <span>Authentication Credentials</span>
                </h3>
                <p className="text-xs text-slate-600 leading-normal">
                  Passwords are cryptographic hashes managed exclusively by Supabase GoTrue authentication. We never store or view plaintext passwords.
                </p>
              </div>
            </div>
          </section>

          {/* Section 3 */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">3</span>
              <span>Google User Data & OAuth Policy</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              When you choose to sign in using <strong>Google Sign-In</strong>:
            </p>
            <ul className="text-sm text-slate-600 space-y-2 list-none pl-1">
              <li className="flex items-start space-x-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <span>We only request basic public profile scopes: your email address, full name, and avatar picture.</span>
              </li>
              <li className="flex items-start space-x-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <span>We do not request access to Google Drive, Contacts, Gmail, or any sensitive Google service.</span>
              </li>
              <li className="flex items-start space-x-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                <span>Your Google data is never sold, leased, or shared with third-party advertisers or external entities.</span>
              </li>
            </ul>
          </section>

          {/* Section 4 */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">4</span>
              <span>Offline Storage & Device Permissions</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              To support Village Study Mode (offline reading in remote areas of Khyber Pakhtunkhwa), textbooks are stored locally on your device storage. We only access storage directories allocated to our application package.
            </p>
          </section>

          {/* Section 5 */}
          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">5</span>
              <span>Data Retention & Account Deletion</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              Users retain full control of their academic profiles. You may update your profile information or request complete deletion of your account and associated study history at any time by contacting us.
            </p>
          </section>

          {/* Section 6 */}
          <section className="space-y-3 border-t border-slate-100 pt-6">
            <h2 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 text-xs flex items-center justify-center font-bold">6</span>
              <span>Contact Us</span>
            </h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              If you have any questions or concerns regarding this Privacy Policy or your personal data:
            </p>
            <div className="p-4 rounded-xl bg-emerald-50/50 border border-emerald-100 text-xs text-slate-700 space-y-1">
              <p><strong>Organization:</strong> Khyber Pakhtunkhwa Textbook Board (KPTBB)</p>
              <p><strong>Address:</strong> Plot No. 18, Sector B-1, Phase-V, Hayatabad, Peshawar, Khyber Pakhtunkhwa</p>
              <p><strong>Official Helpline:</strong> +92 (091) 9217158 / +92 (091) 9217159</p>
              <p><strong>Email:</strong> info@kptbb.gov.pk</p>
              <p><strong>Official Website:</strong> https://kptbb.gov.pk</p>
            </div>
          </section>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-200 py-6 text-center text-xs text-slate-500">
        <p>© 2026 Khyber Pakhtunkhwa Textbook Board. All rights reserved.</p>
        <div className="mt-2 space-x-4">
          <Link href="/privacy" className="text-emerald-700 hover:underline">Privacy Policy</Link>
          <span>•</span>
          <Link href="/terms" className="text-emerald-700 hover:underline">Terms of Service</Link>
        </div>
      </footer>
    </div>
  );
}
