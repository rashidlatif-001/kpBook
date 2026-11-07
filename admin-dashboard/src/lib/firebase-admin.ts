import { getApps, initializeApp, cert, App } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

let firebaseApp: App | null = null;

export function getFirebaseAdmin(): { app: App | null; auth: ReturnType<typeof getAuth> | null } {
  if (firebaseApp) {
    return { app: firebaseApp, auth: getAuth(firebaseApp) };
  }

  const apps = getApps();
  if (apps.length > 0) {
    firebaseApp = apps[0];
    return { app: firebaseApp, auth: getAuth(firebaseApp) };
  }

  const projectId = process.env.FIREBASE_PROJECT_ID || 'kpbooks-dbdcb';
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  try {
    if (clientEmail && privateKey) {
      firebaseApp = initializeApp({
        credential: cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
    } else {
      firebaseApp = initializeApp({
        projectId,
      });
    }
    return { app: firebaseApp, auth: getAuth(firebaseApp) };
  } catch (error) {
    console.warn('Firebase Admin SDK initialized with fallback or disabled:', error);
    return { app: null, auth: null };
  }
}
