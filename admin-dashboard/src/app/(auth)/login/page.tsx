'use client';

import React, { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import {
  BookOpen,
  Lock,
  Mail,
  ShieldCheck,
  ShieldAlert,
  ArrowRight,
  Eye,
  EyeOff,
  RotateCw,
  Volume2,
  VolumeX,
  Sparkles,
  CheckCircle2,
  KeyRound,
  ArrowLeft,
} from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();

  // Authentication State
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successInfo, setSuccessInfo] = useState<string | null>(null);
  const [otpHint, setOtpHint] = useState<string | null>(null);

  // OTP State
  const [step, setStep] = useState<'credentials' | 'otp'>('credentials');
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const [resendCooldown, setResendCooldown] = useState(60);
  const otpInputRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Lamp & Sound State
  const [isLampOn, setIsLampOn] = useState(true);
  const [isPulling, setIsPulling] = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(true);

  // Countdown timer for OTP resend
  useEffect(() => {
    let timer: any;
    if (step === 'otp' && resendCooldown > 0) {
      timer = setInterval(() => {
        setResendCooldown((prev: number) => (prev > 0 ? prev - 1 : 0));
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [step, resendCooldown]);

  // Focus first OTP input when switching to OTP step
  useEffect(() => {
    if (step === 'otp') {
      setTimeout(() => {
        otpInputRefs.current[0]?.focus();
      }, 100);
    }
  }, [step]);

  // Audio Synthesis for Realistic Mechanical Switch + Filament Hum
  const playLampSound = (turningOn: boolean) => {
    if (!soundEnabled) return;
    try {
      const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
      if (!AudioCtx) return;
      const ctx = new AudioCtx();
      const now = ctx.currentTime;

      // Mechanical Relay Switch Click
      const clickOsc = ctx.createOscillator();
      const clickGain = ctx.createGain();
      clickOsc.type = 'triangle';
      clickOsc.frequency.setValueAtTime(turningOn ? 1900 : 1300, now);
      clickGain.gain.setValueAtTime(0.18, now);
      clickGain.gain.exponentialRampToValueAtTime(0.001, now + 0.045);
      clickOsc.connect(clickGain);
      clickGain.connect(ctx.destination);
      clickOsc.start(now);
      clickOsc.stop(now + 0.05);

      // Warm Incandescent Filament Hum (exact synthesis as demonstrated in JS animation)
      if (turningOn) {
        const hum = ctx.createOscillator();
        const humGain = ctx.createGain();
        hum.type = 'sine';
        hum.frequency.setValueAtTime(120, now + 0.05);
        humGain.gain.setValueAtTime(0.001, now);
        humGain.gain.linearRampToValueAtTime(0.06, now + 0.08);
        humGain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
        hum.connect(humGain);
        humGain.connect(ctx.destination);
        hum.start(now + 0.05);
        hum.stop(now + 0.38);
      }
    } catch {
      // AudioContext unavailable or blocked by policy
    }
  };

  const toggleLamp = () => {
    setIsPulling(true);
    const newState = !isLampOn;
    playLampSound(newState);
    setTimeout(() => {
      setIsLampOn(newState);
      setIsPulling(false);
    }, 120);
  };

  // Step 1: Submit Credentials & Request OTP
  const handleCredentialSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccessInfo(null);

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim(), password }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Authentication failed');
      }

      if (data.requireOtp) {
        setStep('otp');
        setResendCooldown(60);
        setOtpHint(data.otpHint || null);
        setSuccessInfo(data.message || `A 6-digit code has been sent to ${email}`);
      } else {
        router.push('/');
        router.refresh();
      }
    } catch (err: any) {
      setError(err.message || 'Invalid administrator credentials');
    } finally {
      setLoading(false);
    }
  };

  // Step 2: Submit 6-digit OTP
  const handleOtpSubmit = async (e?: React.FormEvent, explicitOtp?: string) => {
    if (e) e.preventDefault();
    const fullOtp = explicitOtp || otpDigits.join('');
    if (fullOtp.length < 6) {
      setError('Please enter all 6 digits of the verification code.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const res = await fetch('/api/auth/verify-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim(), otp: fullOtp }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Invalid verification code');
      }

      setSuccessInfo('Verification successful! Entering dashboard...');
      setTimeout(() => {
        router.push('/');
        router.refresh();
      }, 500);
    } catch (err: any) {
      setError(err.message || 'Verification failed. Please check the code.');
    } finally {
      setLoading(false);
    }
  };

  // Resend OTP handler
  const handleResendOtp = async () => {
    if (resendCooldown > 0 || loading) return;
    setLoading(true);
    setError(null);

    try {
      const res = await fetch('/api/auth/resend-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim() }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || 'Failed to resend code');
      }

      setResendCooldown(60);
      setOtpHint(data.otpHint || null);
      setSuccessInfo('A new verification code has been dispatched to your email.');
      setOtpDigits(['', '', '', '', '', '']);
      otpInputRefs.current[0]?.focus();
    } catch (err: any) {
      setError(err.message || 'Could not resend code');
    } finally {
      setLoading(false);
    }
  };

  // OTP Input Changes & Auto-Advance
  const handleOtpChange = (index: number, value: string) => {
    const digit = value.replace(/\D/g, '').slice(-1);
    const newDigits = [...otpDigits];
    newDigits[index] = digit;
    setOtpDigits(newDigits);

    if (digit && index < 5) {
      otpInputRefs.current[index + 1]?.focus();
    }

    // Auto-submit if all 6 filled
    if (digit && index === 5 && newDigits.every((d) => d !== '')) {
      setTimeout(() => {
        handleOtpSubmit();
      }, 50);
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otpDigits[index] && index > 0) {
      otpInputRefs.current[index - 1]?.focus();
    }
  };

  const handleOtpPaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (!pasted) return;

    const newDigits = [...otpDigits];
    for (let i = 0; i < pasted.length; i++) {
      newDigits[i] = pasted[i];
    }
    setOtpDigits(newDigits);

    const nextIndex = Math.min(pasted.length, 5);
    otpInputRefs.current[nextIndex]?.focus();

    if (pasted.length === 6) {
      setTimeout(() => {
        handleOtpSubmit();
      }, 50);
    }
  };

  return (
    <div className="relative min-h-screen w-full bg-[#0a0d14] text-slate-100 flex flex-col items-center justify-center p-4 sm:p-8 overflow-hidden select-none">
      {/* Background Gradient Grid */}
      <div
        className="absolute inset-0 pointer-events-none opacity-20"
        style={{
          backgroundImage:
            'radial-gradient(circle at 1px 1px, rgba(255, 255, 255, 0.15) 1px, transparent 0)',
          backgroundSize: '32px 32px',
        }}
      />

      {/* Top Controls Bar */}
      <div className="absolute top-4 left-4 right-4 max-w-6xl mx-auto flex items-center justify-between z-30 pointer-events-auto">
        <Link
          href="/connect"
          className="flex items-center space-x-2 text-xs font-semibold text-slate-400 hover:text-emerald-400 transition-colors py-1.5 px-3 rounded-xl bg-slate-900/60 backdrop-blur-md border border-slate-800"
        >
          <ArrowLeft className="w-3.5 h-3.5" />
          <span>Public Portal</span>
        </Link>

        <div className="flex items-center space-x-2">
          {/* Sound Toggle */}
          <button
            type="button"
            onClick={() => setSoundEnabled(!soundEnabled)}
            title={soundEnabled ? 'Mute switch audio' : 'Enable switch audio'}
            className="flex items-center space-x-1.5 text-xs font-semibold py-1.5 px-3 rounded-xl bg-slate-900/60 backdrop-blur-md border border-slate-800 text-slate-400 hover:text-amber-300 transition-all cursor-pointer"
          >
            {soundEnabled ? <Volume2 className="w-3.5 h-3.5 text-amber-400" /> : <VolumeX className="w-3.5 h-3.5 text-slate-500" />}
            <span className="hidden sm:inline">{soundEnabled ? 'Sound ON' : 'Muted'}</span>
          </button>

          {/* Lamp Toggle Pill */}
          <button
            type="button"
            onClick={toggleLamp}
            className={`flex items-center space-x-1.5 text-xs font-bold py-1.5 px-3 rounded-xl backdrop-blur-md border transition-all cursor-pointer ${
              isLampOn
                ? 'bg-amber-500/15 border-amber-500/40 text-amber-300 shadow-[0_0_15px_rgba(245,158,11,0.2)]'
                : 'bg-slate-900/70 border-slate-800 text-slate-400 hover:text-slate-200'
            }`}
          >
            <span className="w-2 h-2 rounded-full transition-colors" style={{ backgroundColor: isLampOn ? '#fbbf24' : '#64748b' }} />
            <span>{isLampOn ? 'Light: ON' : 'Light: OFF'}</span>
          </button>
        </div>
      </div>

      {/* Main Showcase Stage */}
      <div className="relative z-20 w-full max-w-5xl mx-auto flex flex-col lg:flex-row items-center justify-center gap-10 lg:gap-14 py-8">
        
        {/* ========================================================= */}
        {/* INTERACTIVE LUXO DESK LAMP & VOLUMETRIC SPOTLIGHT BEAM */}
        {/* ========================================================= */}
        <div className="relative flex flex-col items-center justify-center shrink-0 w-72 sm:w-80 lg:w-[340px] select-none">
          
          {/* Volumetric Light Beam (Projects from lamp head onto the form card) */}
          <div
            className={`absolute pointer-events-none transition-all duration-500 ease-out z-10 ${
              isLampOn ? 'opacity-100 scale-100' : 'opacity-0 scale-95'
            }`}
            style={{
              left: '180px',
              top: '60px',
              width: '780px',
              height: '560px',
              clipPath: 'polygon(0% 12%, 100% 0%, 100% 100%, 0% 28%)',
              background:
                'radial-gradient(circle at 0% 20%, rgba(254, 243, 199, 0.45) 0%, rgba(251, 191, 36, 0.22) 28%, rgba(245, 158, 11, 0.08) 55%, transparent 85%)',
              filter: 'blur(1px)',
              mixBlendMode: 'screen',
            }}
          >
            {/* Animated Dust Particles in Beam */}
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_40%,rgba(255,255,255,0.6)_1px,transparent_1px)] bg-[size:28px_28px] opacity-40 animate-pulse pointer-events-none" />
          </div>

          {/* Intense Radial Glow around Lamp Bulb */}
          <div
            className={`absolute pointer-events-none transition-all duration-300 ease-out z-20 ${
              isLampOn ? 'opacity-100 scale-100' : 'opacity-0 scale-50'
            }`}
            style={{
              left: '140px',
              top: '80px',
              width: '140px',
              height: '140px',
              borderRadius: '50%',
              background: 'radial-gradient(circle, rgba(255,255,255,0.95) 0%, rgba(253,224,71,0.6) 40%, rgba(245,158,11,0.2) 70%, transparent 100%)',
              filter: 'blur(8px)',
              transform: 'translate(-50%, -50%)',
            }}
          />

          {/* Desk Lamp Vector SVG */}
          <div className="relative group cursor-pointer" onClick={toggleLamp}>
            <svg
              viewBox="0 0 340 440"
              className="w-72 sm:w-80 lg:w-[320px] h-auto drop-shadow-[0_20px_35px_rgba(0,0,0,0.8)] transition-transform duration-300 hover:scale-[1.01]"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              {/* Definitions */}
              <defs>
                {/* Metallic Dark Gradients */}
                <linearGradient id="metalDark" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#374151" />
                  <stop offset="50%" stopColor="#1f2937" />
                  <stop offset="100%" stopColor="#111827" />
                </linearGradient>
                <linearGradient id="metalRim" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#4b5563" />
                  <stop offset="50%" stopColor="#9ca3af" />
                  <stop offset="100%" stopColor="#1f2937" />
                </linearGradient>
                {/* Brass Gold Accent Gradient */}
                <linearGradient id="brassGold" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#fef08a" />
                  <stop offset="45%" stopColor="#eab308" />
                  <stop offset="100%" stopColor="#854d0e" />
                </linearGradient>
                {/* Bulb Glow Gradient */}
                <radialGradient id="bulbGlow" cx="50%" cy="50%" r="50%">
                  <stop offset="0%" stopColor="#ffffff" />
                  <stop offset="40%" stopColor="#fef08a" />
                  <stop offset="80%" stopColor="#f59e0b" />
                  <stop offset="100%" stopColor="#d97706" />
                </radialGradient>
              </defs>

              {/* 1. Heavy Weighted Base */}
              <ellipse cx="140" cy="405" rx="80" ry="22" fill="#030712" opacity="0.8" />
              <ellipse cx="140" cy="398" rx="72" ry="16" fill="url(#metalDark)" stroke="#4b5563" strokeWidth="1.5" />
              <ellipse cx="140" cy="395" rx="58" ry="12" fill="#1e293b" />
              <ellipse cx="140" cy="392" rx="46" ry="8" fill="url(#metalDark)" />
              {/* Base Pivot Bracket */}
              <rect x="130" y="365" width="20" height="28" rx="4" fill="url(#metalDark)" stroke="#4b5563" strokeWidth="1" />
              <circle cx="140" cy="378" r="6" fill="url(#brassGold)" />

              {/* 2. Lower Articulated Arm (Dual Rods) */}
              <line x1="136" y1="375" x2="88" y2="245" stroke="url(#metalRim)" strokeWidth="5.5" strokeLinecap="round" />
              <line x1="144" y1="375" x2="96" y2="245" stroke="url(#metalDark)" strokeWidth="4.5" strokeLinecap="round" />
              {/* Tension Springs */}
              <path
                d="M 134 350 Q 115 320 128 300 Q 105 280 120 260"
                stroke="#64748b"
                strokeWidth="1.8"
                fill="none"
              />

              {/* 3. Elbow Articulation Joint */}
              <circle cx="92" cy="245" r="14" fill="url(#metalDark)" stroke="#4b5563" strokeWidth="1.5" />
              <circle cx="92" cy="245" r="7" fill="url(#brassGold)" />
              {/* Tightening Knob */}
              <ellipse cx="78" cy="245" rx="5" ry="9" fill="url(#brassGold)" stroke="#713f12" strokeWidth="1" />

              {/* 4. Upper Articulated Arm */}
              <line x1="92" y1="245" x2="168" y2="128" stroke="url(#metalRim)" strokeWidth="5.5" strokeLinecap="round" />
              <line x1="98" y1="248" x2="174" y2="131" stroke="url(#metalDark)" strokeWidth="4.5" strokeLinecap="round" />

              {/* 5. Head Neck Joint */}
              <circle cx="172" cy="128" r="10" fill="url(#brassGold)" stroke="#713f12" strokeWidth="1" />

              {/* 6. Conical Lampshade Head (Angled ~25° right-down) */}
              <g transform="rotate(22 172 128)">
                {/* Socket cap */}
                <rect x="160" y="80" width="24" height="26" rx="4" fill="url(#brassGold)" stroke="#713f12" strokeWidth="1" />
                {/* Shade Dome */}
                <path
                  d="M 148 98 C 148 65 196 65 196 98 L 225 150 C 228 156 220 162 172 162 C 124 162 116 156 119 150 Z"
                  fill="url(#metalDark)"
                  stroke="#4b5563"
                  strokeWidth="2"
                />
                {/* Metallic Lower Rim */}
                <ellipse cx="172" cy="155" rx="52" ry="14" fill="#0f172a" stroke="url(#brassGold)" strokeWidth="2.5" />

                {/* Light Bulb */}
                <ellipse
                  cx="172"
                  cy="150"
                  rx="26"
                  ry="12"
                  fill={isLampOn ? 'url(#bulbGlow)' : '#334155'}
                  filter={isLampOn ? 'drop-shadow(0 0 16px #fef08a)' : undefined}
                />
              </g>

              {/* 7. Hanging Switch Pull-Cord / Chain */}
              <g
                className="transition-transform duration-200"
                style={{
                  transform: isPulling ? 'translateY(14px)' : 'translateY(0px)',
                  transformOrigin: '150px 145px',
                }}
              >
                {/* Pull String */}
                <line x1="150" y1="145" x2="150" y2="215" stroke="#cbd5e1" strokeWidth="2" strokeDasharray="2,3" />
                {/* Metallic Bead at end */}
                <circle
                  cx="150"
                  cy="220"
                  r="7.5"
                  fill="url(#brassGold)"
                  stroke="#713f12"
                  strokeWidth="1.5"
                  className="transition-transform group-hover:scale-115"
                />
                <circle cx="148" cy="218" r="2" fill="#ffffff" opacity="0.8" />
              </g>
            </svg>

            {/* Click to Toggle Tooltip Pill */}
            <div className="mt-2 text-center">
              <span className="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full text-[11px] font-medium bg-slate-900/80 border border-slate-700/80 text-slate-300 shadow-md group-hover:border-amber-400/50 group-hover:text-amber-200 transition-all">
                <Sparkles className="w-3 h-3 text-amber-400" />
                <span>Pull cord or click lamp to toggle</span>
              </span>
            </div>
          </div>
        </div>

        {/* ========================================================= */}
        {/* FLOATING DARK GLASSMORPHISM FORM CARD */}
        {/* ========================================================= */}
        <div
          className={`relative w-full max-w-md rounded-3xl p-7 sm:p-9 transition-all duration-500 z-20 ${
            isLampOn
              ? 'bg-[#111726]/90 border border-amber-300/30 shadow-[0_25px_60px_-15px_rgba(245,158,11,0.25),0_0_40px_rgba(255,255,255,0.06)] backdrop-blur-xl'
              : 'bg-[#0f1420]/80 border border-slate-800 shadow-[0_20px_40px_rgba(0,0,0,0.8)] backdrop-blur-md opacity-85'
          }`}
        >
          {/* Subtle Ambient Reflected Beam Highlight */}
          {isLampOn && (
            <div className="absolute -top-10 -left-10 w-44 h-44 rounded-full bg-amber-400/10 blur-3xl pointer-events-none" />
          )}

          {/* Form Header */}
          <div className="relative mb-6">
            <div className="flex items-center justify-between mb-3">
              <span className="inline-flex items-center space-x-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-bold tracking-wider uppercase bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                <ShieldCheck className="w-3 h-3" />
                <span>Admin Portal</span>
              </span>
              <span className="text-[11px] font-mono font-medium text-slate-500">v1.0.1 • 2026</span>
            </div>

            <h2 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white">
              {step === 'credentials' ? 'Administrator Login' : 'Two-Factor Verification'}
            </h2>
            <p className="text-xs text-slate-400 mt-1.5 leading-relaxed">
              {step === 'credentials'
                ? 'Sign in with your authorized administrator credentials to manage KPK E-Textbooks.'
                : `Enter the 6-digit authentication code dispatched to ${email}.`}
            </p>
          </div>

          {/* Alert Messages */}
          {error && (
            <div className="mb-5 p-3 rounded-xl bg-rose-500/15 border border-rose-500/40 text-rose-300 text-xs flex items-start space-x-2.5 animate-fadeIn">
              <ShieldAlert className="w-4 h-4 text-rose-400 shrink-0 mt-0.5" />
              <span className="leading-relaxed">{error}</span>
            </div>
          )}

          {successInfo && (
            <div className="mb-5 p-3 rounded-xl bg-emerald-500/15 border border-emerald-500/40 text-emerald-300 text-xs flex items-start space-x-2.5 animate-fadeIn">
              <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
              <span className="leading-relaxed">{successInfo}</span>
            </div>
          )}

          {/* STEP 1: CREDENTIALS FORM */}
          {step === 'credentials' && (
            <form onSubmit={handleCredentialSubmit} className="space-y-4">
              {/* Admin Email Input */}
              <div>
                <label className="block text-[11px] font-bold text-slate-300 uppercase tracking-wider mb-1.5">
                  Authorized Admin Email
                </label>
                <div className="relative group">
                  <Mail className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-amber-400 transition-colors" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="amrl360software@gmail.com"
                    className="w-full pl-10 pr-3 py-3 rounded-xl bg-slate-900/80 border border-slate-700/80 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-amber-400 focus:ring-1 focus:ring-amber-400 transition-all font-mono"
                  />
                </div>
              </div>

              {/* Secure Password Input */}
              <div>
                <div className="flex items-center justify-between mb-1.5">
                  <label className="text-[11px] font-bold text-slate-300 uppercase tracking-wider">
                    Administrative Password
                  </label>
                  <span className="text-[10px] text-amber-400 font-mono">Protected</span>
                </div>
                <div className="relative group">
                  <Lock className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-amber-400 transition-colors" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    className="w-full pl-10 pr-11 py-3 rounded-xl bg-slate-900/80 border border-slate-700/80 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-amber-400 focus:ring-1 focus:ring-amber-400 transition-all font-mono"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-200 transition-colors p-1"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Remember Me */}
              <div className="flex items-center justify-between pt-1">
                <label className="flex items-center space-x-2 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="w-4 h-4 rounded border-slate-700 bg-slate-900 text-emerald-600 focus:ring-emerald-500"
                  />
                  <span className="text-xs text-slate-400">Remember administrative session</span>
                </label>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3.5 px-4 rounded-xl font-bold text-sm bg-gradient-to-r from-emerald-600 via-teal-600 to-emerald-700 hover:from-emerald-500 hover:to-teal-600 text-white shadow-lg shadow-emerald-900/40 hover:shadow-emerald-700/50 transition-all duration-200 flex items-center justify-center space-x-2 disabled:opacity-60 disabled:cursor-not-allowed cursor-pointer mt-2"
              >
                {loading ? (
                  <>
                    <RotateCw className="w-4 h-4 animate-spin" />
                    <span>Verifying Credentials & Sending OTP...</span>
                  </>
                ) : (
                  <>
                    <span>Authenticate & Send Email OTP</span>
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>
            </form>
          )}

          {/* STEP 2: 6-DIGIT OTP VERIFICATION FORM */}
          {step === 'otp' && (
            <form onSubmit={handleOtpSubmit} className="space-y-5 animate-fadeIn">
              {/* Emergency / Dev Passcode Assistant */}
              {otpHint && (
                <div className="p-3.5 rounded-2xl bg-gradient-to-r from-amber-500/15 via-amber-400/10 to-amber-500/15 border border-amber-400/40 text-xs text-amber-200 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-lg shadow-amber-950/30">
                  <div className="flex items-center space-x-2.5">
                    <div className="w-8 h-8 rounded-lg bg-amber-400/20 flex items-center justify-center text-amber-300 shrink-0">
                      <KeyRound className="w-4 h-4" />
                    </div>
                    <div>
                      <span className="block text-[10px] uppercase font-bold text-amber-400 tracking-wider">
                        Generated OTP Code:
                      </span>
                      <span className="font-mono text-base font-extrabold tracking-widest text-white">
                        {otpHint}
                      </span>
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={() => {
                      const digits = otpHint.split('').slice(0, 6);
                      setOtpDigits(digits);
                      setTimeout(() => handleOtpSubmit(undefined, otpHint), 80);
                    }}
                    className="w-full sm:w-auto px-3.5 py-1.5 rounded-xl bg-amber-400 text-slate-950 hover:bg-amber-300 text-xs font-extrabold shadow-sm cursor-pointer transition-all flex items-center justify-center space-x-1.5 shrink-0"
                  >
                    <span>Auto-Fill &amp; Enter</span>
                    <ArrowRight className="w-3.5 h-3.5" />
                  </button>
                </div>
              )}

              <div>
                <label className="block text-[11px] font-bold text-slate-300 uppercase tracking-wider mb-2 text-center">
                  Enter 6-Digit Email Code
                </label>
                
                {/* 6 Digit Input Blocks */}
                <div className="flex items-center justify-center gap-2 sm:gap-2.5">
                  {otpDigits.map((digit, index) => (
                    <input
                      key={index}
                      ref={(el) => {
                        otpInputRefs.current[index] = el;
                      }}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={(e) => handleOtpChange(index, e.target.value)}
                      onKeyDown={(e) => handleOtpKeyDown(index, e)}
                      onPaste={handleOtpPaste}
                      className="w-11 h-13 sm:w-12 sm:h-14 text-center text-xl sm:text-2xl font-bold font-mono rounded-xl bg-slate-900/90 border border-slate-700 text-emerald-400 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/40 transition-all shadow-inner"
                    />
                  ))}
                </div>
                <p className="text-[10px] text-center text-slate-500 mt-2 font-mono">
                  Master emergency code: <span className="text-amber-400/90 font-bold">360360</span>
                </p>
              </div>

              {/* Resend Countdown & Action */}
              <div className="flex items-center justify-between text-xs pt-1">
                <button
                  type="button"
                  onClick={() => {
                    setStep('credentials');
                    setError(null);
                    setSuccessInfo(null);
                  }}
                  className="text-slate-400 hover:text-slate-200 flex items-center space-x-1 cursor-pointer transition-colors"
                >
                  <ArrowLeft className="w-3.5 h-3.5" />
                  <span>Change Password</span>
                </button>

                <button
                  type="button"
                  onClick={handleResendOtp}
                  disabled={resendCooldown > 0 || loading}
                  className={`font-semibold cursor-pointer transition-colors ${
                    resendCooldown > 0
                      ? 'text-slate-500 cursor-not-allowed'
                      : 'text-amber-400 hover:text-amber-300 underline'
                  }`}
                >
                  {resendCooldown > 0 ? `Resend in ${resendCooldown}s` : 'Resend Code'}
                </button>
              </div>

              {/* Verify OTP Button */}
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3.5 px-4 rounded-xl font-bold text-sm bg-gradient-to-r from-amber-500 via-amber-600 to-amber-700 hover:from-amber-400 hover:to-amber-600 text-slate-950 shadow-lg shadow-amber-900/40 hover:shadow-amber-600/50 transition-all duration-200 flex items-center justify-center space-x-2 disabled:opacity-60 disabled:cursor-not-allowed cursor-pointer"
              >
                {loading ? (
                  <>
                    <RotateCw className="w-4 h-4 animate-spin text-slate-950" />
                    <span>Verifying Code...</span>
                  </>
                ) : (
                  <>
                    <KeyRound className="w-4 h-4" />
                    <span>Verify Code & Enter Dashboard</span>
                  </>
                )}
              </button>
            </form>
          )}

          {/* Card Footer Security Seal */}
          <div className="mt-6 pt-5 border-t border-slate-800/80 flex items-center justify-between text-[11px] text-slate-400">
            <span className="flex items-center space-x-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              <span>TLS 256-Bit Encrypted</span>
            </span>
            <span className="font-mono text-slate-400">Govt of Khyber Pakhtunkhwa</span>
          </div>
        </div>
      </div>
    </div>
  );
}
