# KPK Books – Web-Based Admin Dashboard (Vercel Production)

> **Government of Khyber Pakhtunkhwa • Education Administration & User Management Portal**

This is the official Web-Based Admin Dashboard for the **KPK Books** (Pakhtunkhwa Ilm) Flutter mobile application. It is built with **Next.js 16 (App Router)**, **TypeScript**, **Tailwind CSS**, and connects directly to the same **Supabase** and **Firebase** backend used by the mobile application.

---

## 🚀 Key Features

1. **Dashboard Analytics & Real-Time Metrics:**
   - Total Registered Students.
   - Today's Registrations, Weekly Signups, and Monthly Growth.
   - Active Students (30-day window) vs. Inactive Accounts.
   - 7-Day Student Registration Trend Chart.
   - Class-Wise User Distribution (Class 1 to 12).

2. **Complete User Management:**
   - Real-time synchronization from Flutter app mobile registrations.
   - Live Search by Name, Email, Phone, District, and School.
   - Filters by Grade / Class (Class 1–12), District (Peshawar, Mardan, Swat, etc.), and Status.
   - Sorting by Registration Date, Name, Class, and Last Login.
   - Pagination (10, 25, 50 rows per page).
   - User Profile Modal with complete academic and demographic audit trail.
   - **One-Click CSV Export** for official reporting and analysis.

3. **Authentication & Session Audit Trail:**
   - Live stream of mobile app logins with timestamps, IP address, and device type.
   - Textbook engagements (downloads, searches, reads).
   - Separate, secure Admin Authentication with bcrypt password hashing and JWT sessions.

4. **Multi-Platform Architecture:**
   - Mobile students use the Flutter app.
   - Administrators access the web dashboard via any browser at `https://kpk-books-admin.vercel.app`.
   - Automatic PostgreSQL trigger (`on_auth_user_created`) synchronizes every new signup from the mobile app into the dashboard immediately.

---

## 🔑 Default Administrator Credentials

| Field | Value |
|---|---|
| **Portal URL** | `https://kpk-books-admin.vercel.app/login` (or `http://localhost:3000/login`) |
| **Email** | `admin@kpbooks.gov.pk` |
| **Password** | `Admin@Kpk2026!` |
| **Role** | Super Administrator |

*(You can update this password or create additional admin users anytime in the `public.admin_users` table).*

---

## 🛠️ Local Development Quickstart

1. Navigate to the `admin-dashboard` folder:
   ```bash
   cd admin-dashboard
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Ensure `.env.local` is present (already configured with local credentials):
   ```bash
   npm run dev
   ```

4. Open your browser at [http://localhost:3000](http://localhost:3000).

---

## 🌐 Vercel Production Deployment Guide

### Option 1: Deploy via Vercel Web Dashboard (Recommended)

1. Push your repository to **GitHub**:
   ```bash
   git add .
   git commit -m "feat(admin): complete KPK Books web admin dashboard"
   git push origin main
   ```

2. Open [https://vercel.com/new](https://vercel.com/new) and click **"Import"** next to your `kpBook` repository.

3. In the project configuration screen:
   * **Project Name:** `kpk-books-admin`
   * **Framework Preset:** `Next.js`
   * **Root Directory:** Click **Edit** and select **`admin-dashboard`** *(CRITICAL!)*
   * **Build Command:** `npm run build` (Default)
   * **Output Directory:** `.next` (Default)

4. Under **Environment Variables**, add the following:

   | Variable Name | Value |
   |---|---|
   | `DATABASE_URL` | `postgresql://postgres.tsqypxgfaajwqcgtfdkq:Latif.00100@aws-0-eu-west-1.pooler.supabase.com:6543/postgres` |
   | `NEXT_PUBLIC_SUPABASE_URL` | `https://tsqypxgfaajwqcgtfdkq.supabase.co` |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `sb_publishable_RQ8BvygKqcRAxmndpRt_OQ_PMtfMF6x` |
   | `JWT_SECRET` | `kpk-books-secret-jwt-key-2026-super-secure-token-998877` |
   | `ADMIN_SESSION_COOKIE` | `kpk_admin_session` |
   | `SYNC_API_SECRET` | `kpk-books-sync-secret-key-2026-auth-event-token` |
   | `FIREBASE_PROJECT_ID` | `kpbooks-dbdcb` |
   | `FIREBASE_CLIENT_EMAIL` | `firebase-adminsdk-fbsvc@kpbooks-dbdcb.iam.gserviceaccount.com` |

5. Click **"Deploy"**. Vercel will build and launch your production site at:
   `https://kpk-books-admin.vercel.app`

---

### Option 2: Deploy via Vercel CLI

1. Install the Vercel CLI if not already installed:
   ```bash
   npm install -g vercel
   ```

2. From inside the `admin-dashboard` folder, run:
   ```bash
   cd admin-dashboard
   vercel
   ```

3. For production deployment:
   ```bash
   vercel --prod
   ```

---

## 🔒 Security Architecture

- **Separation of Concerns:** Mobile app users registered through Flutter do NOT have dashboard administrator rights.
- **Server-Side Queries:** Database queries, passwords, and sessions are verified exclusively on the server side using the Supabase connection pooler and bcrypt.
- **Zero Secrets in Client Code:** Service role keys and connection strings are never bundled into client JavaScript.
- **Protected Routes:** All dashboard endpoints and pages (`/`, `/users`, `/activity`, `/analytics`, `/settings`) are protected by edge middleware validating encrypted JWT session cookies.
