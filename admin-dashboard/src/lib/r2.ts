import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const accountId = process.env.R2_ACCOUNT_ID || '';
const accessKeyId = process.env.R2_ACCESS_KEY_ID || '';
const secretAccessKey = process.env.R2_SECRET_ACCESS_KEY || '';
const bucketName = process.env.R2_BUCKET_NAME || 'kp-books';
const publicDomain = process.env.R2_PUBLIC_DOMAIN || '';

export const isR2Configured = Boolean(accountId && accessKeyId && secretAccessKey);

export function getR2Client(): S3Client {
  return new S3Client({
    region: 'auto',
    endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });
}

/**
 * Generate a presigned PUT URL for direct client-to-R2 upload (bypasses Vercel payload limit)
 */
export async function getR2PresignedUploadUrl(
  filename: string,
  contentType = 'application/pdf',
  expiresIn = 3600
): Promise<{ uploadUrl: string; publicUrl: string }> {
  if (!isR2Configured) {
    throw new Error('Cloudflare R2 is not configured. Missing R2 environment variables.');
  }

  const s3 = getR2Client();
  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: filename,
    ContentType: contentType,
  });

  const uploadUrl = await getSignedUrl(s3, command, { expiresIn });
  
  // Clean public domain URL
  const domain = publicDomain.endsWith('/') ? publicDomain.slice(0, -1) : publicDomain;
  const publicUrl = domain ? `${domain}/${filename}` : `https://${bucketName}.${accountId}.r2.cloudflarestorage.com/${filename}`;

  return { uploadUrl, publicUrl };
}
