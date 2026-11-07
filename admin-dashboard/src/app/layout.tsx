import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'KPK Books – Web-Based Admin Dashboard',
  description: 'Education administration and user management portal for KPK E-Textbooks (Pakhtunkhwa Ilm)',
  icons: {
    icon: '/favicon.ico',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full bg-slate-50 text-slate-900 font-sans">
        {children}
      </body>
    </html>
  );
}
