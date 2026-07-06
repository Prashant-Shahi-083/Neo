# NEO Platform Architecture

## Current Stack
- **Database**: PostgreSQL (Entities scaled up to support full dynamic homepage structures)
- **Backend API**: NestJS (Node.js, TypeScript)
- **Admin Dashboard**: Next.js (React, Tailwind CSS, NeoTheme)
- **Storage**: Local filesystem via chunked uploads (`/uploads/temp` and `/uploads/media`).
- **Media Processing**: 
  - Audio: FFmpeg via `fluent-ffmpeg` (Metadata, Waveforms, Previews)
  - Images: `sharp` (Thumbnails, Resizing, Compression)

## System Components
1. **Core Entities**: User, Artist, Album, Song, Genre, Playlist, MediaUpload, AuditLog.
2. **CMS Core**: `HomepageSection` and `HomepageItem` power a 100% dynamic, API-driven homepage layout ensuring the mobile client relies on zero hardcoded components.
3. **Upload Pipeline**: Supports chunked multi-file uploads with AbortController for pause/resume. In-memory asynchronous hook system simulates enterprise queues.
