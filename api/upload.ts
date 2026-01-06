import { put } from '@vercel/blob';
import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).send('Method not allowed');
  }

  const auth = req.headers['x-upload-secret'];
  if (auth !== process.env.UPLOAD_SECRET) {
    return res.status(401).send('Unauthorized');
  }

  const { filename, contentType } = req.body || {};

  if (!filename || !contentType) {
    return res.status(400).send('Missing filename or contentType');
  }

  const blob = await put(
    `screenshots/${filename}`,
    null,
    {
      access: 'public',
      contentType,
      addRandomSuffix: false,
    }
  );

  res.status(200).json(blob);
}

