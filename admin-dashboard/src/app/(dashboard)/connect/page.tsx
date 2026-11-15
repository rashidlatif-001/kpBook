import React from 'react';
import Link from 'next/link';
import {
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
} from 'lucide-react';

export const metadata = {
  title: 'Connect & App Information | KPK Books Administration',
  description: 'Official directory of helplines, BISE examination boards, and legal policies for KPK E-Textbooks.',
};

const biseBoards = [
  {
    name: 'BISE Peshawar',
    tag: 'Central HQ',
    coverage: 'Peshawar, Charsadda, Khyber',
    phone: '091-9221404',
    website: 'https://bisep.edu.pk',
  },
  {
    name: 'BISE Abbottabad',
    tag: 'Hazara Division',
    coverage: 'Abbottabad, Haripur, Mansehra, Battagram',
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
    coverage: 'Kohat, Karak, Hangu, Kurram',
    phone: '0922-554619',
    website: 'https://bisekt.edu.pk',
  },
  {
    name: 'BISE Bannu',
    tag: 'Bannu Division',
    coverage: 'Bannu, Lakki Marwat, North Waziristan',
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

export default function ConnectPage() {
  return (
    <div className="space-y-8 max-w-6xl">
      {/* Page Header */}
      <div>
        <div className="flex items-center space-x-2 text-emerald-700 text-xs font-bold uppercase tracking-wider mb-1">
          <ShieldCheck className="w-4 h-4" />
          <span>Government of Khyber Pakhtunkhwa</span>
        </div>
        <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight">
          Connect & App Accreditation Directory
        </h1>
        <p className="text-sm text-slate-500 mt-1">
          Official helplines, regional BISE examination boards, and student legal & privacy policies.
        </p>
      </div>

      {/* Official Government Accreditation Banner */}
      <div className="p-6 rounded-2xl bg-gradient-to-r from-emerald-900 via-emerald-800 to-teal-900 text-white shadow-lg relative overflow-hidden">
        <div className="absolute right-0 top-0 bottom-0 w-80 bg-white/5 rounded-full blur-2xl pointer-events-none" />
        <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          <div className="space-y-2">
            <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-emerald-700/60 border border-emerald-500/40 text-xs font-semibold text-emerald-100">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-300" />
              <span>Official Public EdTech Platform</span>
            </span>
            <h2 className="text-xl font-bold">Khyber Pakhtunkhwa Textbook Board (KPTBB)</h2>
            <p className="text-xs text-emerald-200/90 max-w-2xl leading-relaxed">
              Elementary & Secondary Education Department (E&SED) • Directorate of Curriculum & Teacher Education (DCTE).
              Distributed under the KP Digital Governance & Education Access Initiative — 100% Free of cost for all students across KP.
            </p>
          </div>
          <div className="p-4 rounded-xl bg-white/10 backdrop-blur-md border border-white/20 text-center shrink-0">
            <span className="text-xs text-emerald-200 uppercase font-bold tracking-wider block">Toll-Free Helpline</span>
            <span className="text-2xl font-extrabold text-white font-mono mt-0.5 block">0800-575456</span>
            <span className="text-[11px] text-emerald-300">(0800-KPK-ILM)</span>
          </div>
        </div>
      </div>

      {/* Support Desks Grid */}
      <div className="grid md:grid-cols-3 gap-4">
        {/* Physical Address */}
        <div className="p-5 rounded-xl bg-white border border-slate-200 shadow-xs space-y-3">
          <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
            <MapPin className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Headquarters Address</h3>
            <p className="text-xs text-slate-600 mt-1 leading-relaxed">
              Plot No. 18, Sector B-1, Phase-V, Hayatabad, Peshawar, Khyber Pakhtunkhwa
            </p>
          </div>
          <div className="text-[11px] text-slate-500 font-mono pt-1">
            Office Hours: 8:00 AM – 4:00 PM
          </div>
        </div>

        {/* WhatsApp Desk */}
        <div className="p-5 rounded-xl bg-white border border-slate-200 shadow-xs space-y-3">
          <div className="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
            <MessageCircle className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">WhatsApp Desk</h3>
            <p className="text-xs text-slate-600 mt-1 leading-relaxed">
              Direct student query desk for syllabus updates and model paper guides.
            </p>
          </div>
          <div className="text-xs font-bold text-emerald-700 pt-1">
            +92 300 1234567
          </div>
        </div>

        {/* Email Bureau */}
        <div className="p-5 rounded-xl bg-white border border-slate-200 shadow-xs space-y-3">
          <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center">
            <Mail className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Official Email Bureau</h3>
            <p className="text-xs text-slate-600 mt-1 leading-relaxed">
              Inquiries, feedback, and academic verification requests.
            </p>
          </div>
          <div className="text-xs font-mono font-semibold text-blue-700 pt-1 truncate">
            info@kptbb.gov.pk
          </div>
        </div>
      </div>

      {/* Regional BISE Boards Directory */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-6 space-y-6">
        <div className="flex items-center justify-between border-b border-slate-100 pb-4">
          <div>
            <h2 className="text-base font-bold text-slate-900 flex items-center space-x-2">
              <Building2 className="w-5 h-5 text-emerald-700" />
              <span>Regional BISE Examination Boards (8 Regional Centers)</span>
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">
              Contact numbers, jurisdictions, and official portals for roll numbers and examination slips.
            </p>
          </div>
          <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-slate-100 text-slate-700">
            8 Regional Boards
          </span>
        </div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {biseBoards.map((b) => (
            <div key={b.name} className="p-4 rounded-xl bg-slate-50 border border-slate-200/80 flex flex-col justify-between space-y-3">
              <div>
                <div className="flex items-center justify-between">
                  <span className="text-[10px] font-bold font-mono text-emerald-700 bg-emerald-100/70 px-1.5 py-0.5 rounded">
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
                  className="w-7 h-7 rounded-lg bg-emerald-100/80 text-emerald-800 flex items-center justify-center hover:bg-emerald-200"
                >
                  <PhoneCall className="w-3.5 h-3.5" />
                </a>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Legal & Policy Quick Links */}
      <div className="bg-slate-900 text-white rounded-2xl p-6 shadow-sm flex flex-col md:flex-row items-center justify-between gap-4">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center text-emerald-400">
            <FileText className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-white">Student Data Privacy & Terms of Service</h3>
            <p className="text-xs text-slate-400">Official legal documents compliant with Google OAuth & student data protection.</p>
          </div>
        </div>
        <div className="flex items-center space-x-3 shrink-0">
          <Link
            href="/privacy"
            target="_blank"
            className="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold flex items-center space-x-1.5"
          >
            <span>Privacy Policy</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </Link>
          <Link
            href="/terms"
            target="_blank"
            className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold flex items-center space-x-1.5 border border-slate-700"
          >
            <span>Terms of Service</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </Link>
        </div>
      </div>
    </div>
  );
}
