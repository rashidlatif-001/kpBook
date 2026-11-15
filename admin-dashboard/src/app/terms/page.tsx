import React from 'react';
import Link from 'next/link';
import { BookOpen, Scale, CheckCircle2, ArrowLeft } from 'lucide-react';

export const metadata = {
  title: 'Terms of Service | KPK E-Textbooks (Pakhtunkhwa Ilm)',
  description: 'Terms of Service for KPK E-Textbooks official mobile application and educational resources.',
};

export default function TermsOfServicePage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      {/* Header */}
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
              <Scale className="w-3.5 h-3.5" />
              <span>Terms of Service</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
              Terms of Service & Academic Usage
            </h1>
            <p className="text-xs text-slate-500 mt-2">
              Last updated: November 15, 2026 • Official Terms for Pakhtunkhwa Ilm Educational Platform
            </p>
          </div>

          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">1. Acceptance of Terms</h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              By downloading, accessing, or using the <strong>Pakhtunkhwa Ilm (KPK E-Textbooks)</strong> mobile application, you agree to comply with and be bound by these Terms of Service. These services are provided free of cost to support learning across Khyber Pakhtunkhwa.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">2. Official Curriculum Intellectual Property</h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              All textbook contents, syllabi, SLO guides, diagrams, and model exam papers are the intellectual property of the Khyber Pakhtunkhwa Textbook Board. Students and teachers are granted a non-exclusive license for personal educational use. Unauthorized commercial resale or distribution is strictly prohibited.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">3. User Accounts & Google Authentication</h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              Users may authenticate using Email & Password or Google Sign-In. You are responsible for maintaining the confidentiality of your credentials. You agree to use the application solely for lawful academic and educational purposes.
            </p>
          </section>

          <section className="space-y-3">
            <h2 className="text-lg font-bold text-slate-900">4. Service Availability & Offline Mode</h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              While we strive for continuous service uptime, online synchronization and textbook downloads are subject to internet connectivity. Downloaded materials remain accessible indefinitely in Village Study Mode without active cellular reception.
            </p>
          </section>

          <section className="space-y-3 border-t border-slate-100 pt-6">
            <h2 className="text-lg font-bold text-slate-900">5. Contact Information</h2>
            <p className="text-sm text-slate-600 leading-relaxed">
              For academic syllabus queries or technical assistance, contact the textbook committee at <span className="font-semibold text-emerald-800">info@kptbb.gov.pk</span> or visit our headquarters at Plot No. 18, Sector B-1, Phase-V, Hayatabad, Peshawar.
            </p>
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
