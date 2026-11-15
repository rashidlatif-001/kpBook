import React from 'react';
import Link from 'next/link';
import {
  BookOpen,
  PhoneCall,
  Mail,
  MapPin,
  Building2,
  ExternalLink,
  ShieldCheck,
  Globe,
  MessageCircle,
  FileText,
  CheckCircle2,
  ArrowRight,
  Headphones,
} from 'lucide-react';

export const metadata = {
  title: 'Connect With Us & App Information | KPK E-Textbooks (Pakhtunkhwa Ilm)',
  description: 'Official portal for KPK E-Textbooks helplines, regional BISE examination boards, and student policies.',
};

const biseBoards = [
  {
    name: 'BISE Peshawar',
    tag: 'HQ Central',
    coverage: 'Peshawar, Charsadda, Khyber',
    phone: '091-9221404',
    website: 'https://bisep.edu.pk',
  },
  {
    name: 'BISE Abbottabad',
    tag: 'Hazara Division',
    coverage: 'Abbottabad, Haripur, Mansehra',
    phone: '0992-381134',
    website: 'https://biseatd.edu.pk',
  },
  {
    name: 'BISE Swat',
    tag: 'Malakand Division',
    coverage: 'Swat, Buner, Shangla',
    phone: '0946-9240400',
    website: 'https://bisess.edu.pk',
  },
  {
    name: 'BISE Mardan',
    tag: 'Mardan / Swabi',
    coverage: 'Mardan, Swabi, Nowshera',
    phone: '0937-9230279',
    website: 'https://bisemdn.edu.pk',
  },
  {
    name: 'BISE Kohat',
    tag: 'Kohat Division',
    coverage: 'Kohat, Karak, Hangu',
    phone: '0922-554619',
    website: 'https://bisekt.edu.pk',
  },
  {
    name: 'BISE Bannu',
    tag: 'Bannu Division',
    coverage: 'Bannu, Lakki Marwat',
    phone: '0928-633170',
    website: 'https://biseb.edu.pk',
  },
  {
    name: 'BISE Malakand',
    tag: 'Northern KP',
    coverage: 'Lower/Upper Dir, Malakand, Bajaur',
    phone: '0932-452140',
    website: 'https://bisemalakand.edu.pk',
  },
  {
    name: 'BISE D.I. Khan',
    tag: 'Southern KP',
    coverage: 'Dera Ismail Khan, Tank, South Waziristan',
    phone: '0966-9280145',
    website: 'https://bisedik.edu.pk',
  },
];

export default function PublicConnectPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      {/* Top Government Navigation Header */}
      <header className="border-b border-slate-200 bg-white sticky top-0 z-30 shadow-xs">
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-700 flex items-center justify-center text-white shadow-sm">
              <BookOpen className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h1 className="text-base font-bold text-slate-900 leading-tight">KPK E-Textbooks</h1>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
                  رابطہ و معلومات
                </span>
              </div>
              <p className="text-xs text-slate-500">Khyber Pakhtunkhwa Textbook Board • Government of KP</p>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <Link
              href="/terms"
              className="text-xs font-semibold text-slate-600 hover:text-emerald-700 px-3 py-1.5 rounded-lg border border-slate-200 hover:border-emerald-300"
            >
              Terms of Service
            </Link>
            <Link
              href="/privacy"
              className="text-xs font-semibold text-slate-600 hover:text-emerald-700 px-3 py-1.5 rounded-lg border border-slate-200 hover:border-emerald-300"
            >
              Privacy Policy
            </Link>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-5xl mx-auto px-4 py-8 space-y-8">
        {/* Accreditation Hero Card */}
        <section className="rounded-2xl bg-gradient-to-r from-emerald-900 via-emerald-800 to-teal-950 text-white p-6 sm:p-8 shadow-lg relative overflow-hidden">
          <div className="absolute right-0 top-0 bottom-0 w-96 bg-white/5 rounded-full blur-3xl pointer-events-none" />
          <div className="relative z-10 space-y-4">
            <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-emerald-700/60 border border-emerald-500/40 text-xs font-semibold text-emerald-100">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-300" />
              <span>Official Public Education Initiative</span>
            </div>
            <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
              Connect With Us & App Information
            </h2>
            <p className="text-sm text-emerald-200/90 max-w-2xl leading-relaxed">
              Elementary & Secondary Education Department (E&SED), Government of Khyber Pakhtunkhwa.
              Providing 100% free offline-ready curriculum textbooks from Class 1 to Class 12 for students across all regional terrains.
            </p>
            <div className="pt-2 flex flex-wrap items-center gap-4 text-xs text-emerald-200 font-mono">
              <span className="flex items-center space-x-1.5 bg-white/10 px-3 py-1.5 rounded-lg">
                <ShieldCheck className="w-4 h-4 text-emerald-300" />
                <span>Curriculum 2024–25 Verified</span>
              </span>
              <span className="flex items-center space-x-1.5 bg-white/10 px-3 py-1.5 rounded-lg">
                <Globe className="w-4 h-4 text-emerald-300" />
                <span>KPTBB Hayatabad Peshawar</span>
              </span>
            </div>
          </div>
        </section>

        {/* Toll-Free & Direct Student Support Cards */}
        <section className="grid sm:grid-cols-3 gap-4">
          {/* Toll Free */}
          <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm flex flex-col justify-between space-y-4">
            <div className="flex items-start justify-between">
              <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
                <PhoneCall className="w-6 h-6" />
              </div>
              <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-emerald-100 text-emerald-800">
                Toll-Free
              </span>
            </div>
            <div>
              <p className="text-xs text-slate-500 font-medium">Toll-Free Student Line</p>
              <h3 className="text-xl font-extrabold text-slate-900 font-mono mt-0.5">0800-575456</h3>
              <p className="text-[11px] text-slate-400 font-mono">(0800-KPK-ILM)</p>
            </div>
            <a
              href="tel:0800575456"
              className="w-full py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold text-center block transition-colors"
            >
              Call Student Helpline
            </a>
          </div>

          {/* WhatsApp Desk */}
          <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm flex flex-col justify-between space-y-4">
            <div className="flex items-start justify-between">
              <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
                <MessageCircle className="w-6 h-6" />
              </div>
              <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-emerald-100 text-emerald-800">
                WhatsApp
              </span>
            </div>
            <div>
              <p className="text-xs text-slate-500 font-medium">WhatsApp Community Desk</p>
              <h3 className="text-base font-bold text-slate-900 mt-0.5">+92 300 1234567</h3>
              <p className="text-[11px] text-slate-500">Syllabus updates & model papers</p>
            </div>
            <a
              href="https://wa.me/923001234567"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full py-2.5 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200 text-xs font-bold text-center block transition-colors"
            >
              Open WhatsApp Desk
            </a>
          </div>

          {/* Email Bureau */}
          <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-sm flex flex-col justify-between space-y-4">
            <div className="flex items-start justify-between">
              <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center">
                <Mail className="w-6 h-6" />
              </div>
              <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded bg-blue-100 text-blue-800">
                Email
              </span>
            </div>
            <div>
              <p className="text-xs text-slate-500 font-medium">Official Email Bureau</p>
              <h3 className="text-sm font-bold text-slate-900 font-mono mt-0.5 truncate">info@kptbb.gov.pk</h3>
              <p className="text-[11px] text-slate-500">Official feedback & queries</p>
            </div>
            <a
              href="mailto:info@kptbb.gov.pk"
              className="w-full py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold text-center block transition-colors"
            >
              Send Official Email
            </a>
          </div>
        </section>

        {/* Physical Headquarters Address */}
        <section className="p-5 rounded-2xl bg-white border border-slate-200 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-start space-x-3.5">
            <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-700 flex items-center justify-center shrink-0">
              <MapPin className="w-5 h-5 text-emerald-700" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">KPK Textbook Board Headquarters</h3>
              <p className="text-xs text-slate-600 mt-0.5">Plot No. 18, Sector B-1, Phase-V, Hayatabad, Peshawar, Khyber Pakhtunkhwa</p>
              <p className="text-[11px] text-slate-400 font-mono mt-1">Helpline: +92 (091) 9217158 • Hours: Mon–Fri, 8 AM – 4 PM</p>
            </div>
          </div>
          <a
            href="https://kptbb.gov.pk"
            target="_blank"
            rel="noopener noreferrer"
            className="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold flex items-center space-x-1.5 shrink-0"
          >
            <span>Visit KPTBB Portal</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
        </section>

        {/* 8 Regional BISE Boards */}
        <section className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 sm:p-8 space-y-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-100 pb-4">
            <div>
              <h3 className="text-lg font-bold text-slate-900 flex items-center space-x-2">
                <Building2 className="w-5 h-5 text-emerald-700" />
                <span>Regional BISE Examination Boards Directory</span>
              </h3>
              <p className="text-xs text-slate-500 mt-1">
                Official contact numbers and online portals for examination slips, results, and curriculum inquiries across all 8 boards in KP.
              </p>
            </div>
            <span className="text-xs font-bold px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 w-fit">
              8 Regional Centers
            </span>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {biseBoards.map((b) => (
              <div key={b.name} className="p-4 rounded-xl bg-slate-50 border border-slate-200/80 flex flex-col justify-between space-y-3">
                <div>
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] font-bold font-mono text-emerald-800 bg-emerald-100 px-1.5 py-0.5 rounded">
                      {b.tag}
                    </span>
                    <a href={b.website} target="_blank" rel="noopener noreferrer" className="text-slate-400 hover:text-emerald-700">
                      <Globe className="w-3.5 h-3.5" />
                    </a>
                  </div>
                  <h4 className="text-sm font-bold text-slate-900 mt-2">{b.name}</h4>
                  <p className="text-xs text-slate-500 mt-1 line-clamp-2">{b.coverage}</p>
                </div>
                <div className="pt-2 border-t border-slate-200/60 flex items-center justify-between">
                  <span className="font-mono text-xs font-semibold text-slate-700">{b.phone}</span>
                  <a
                    href={`tel:${b.phone}`}
                    className="w-7 h-7 rounded-lg bg-emerald-100 text-emerald-800 flex items-center justify-center hover:bg-emerald-200"
                  >
                    <PhoneCall className="w-3.5 h-3.5" />
                  </a>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Legal Policies Quick Access */}
        <section className="bg-slate-900 text-white rounded-2xl p-6 sm:p-8 shadow-sm flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-start space-x-4">
            <div className="w-12 h-12 rounded-2xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
              <FileText className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-base font-bold text-white">Student Data Privacy & Legal Compliance</h3>
              <p className="text-xs text-slate-400 mt-1 leading-relaxed max-w-xl">
                Our application protects student records with end-to-end Supabase cryptographic token architecture and complies fully with Google OAuth public data standards.
              </p>
            </div>
          </div>
          <div className="flex items-center space-x-3 shrink-0">
            <Link
              href="/privacy"
              className="px-4 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold flex items-center space-x-1.5 transition-colors"
            >
              <span>Privacy Policy</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
            <Link
              href="/terms"
              className="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold flex items-center space-x-1.5 border border-slate-700 transition-colors"
            >
              <span>Terms of Service</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-200 py-6 text-center text-xs text-slate-500 bg-white">
        <p>© 2026 Government of Khyber Pakhtunkhwa. Distributed under the KP Digital Governance & Education Access Initiative.</p>
        <div className="mt-2 space-x-4">
          <Link href="/privacy" className="text-emerald-700 hover:underline">Privacy Policy</Link>
          <span>•</span>
          <Link href="/terms" className="text-emerald-700 hover:underline">Terms of Service</Link>
          <span>•</span>
          <Link href="/connect" className="text-emerald-700 hover:underline">Connect With Us</Link>
        </div>
      </footer>
    </div>
  );
}
