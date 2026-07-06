# NEO Platform Database Schema

## Core Content Entities
- **Artist**: `id`, `name`, `bio`, `photoUrl`, `isVerified`, `isActive`
- **Album**: `id`, `title`, `description`, `releaseDate`, `coverUrl`, `status`
- **Genre**: `id`, `name`
- **Song**: 20+ columns handling deep metadata (`isrc`, `durationMs`, `audioFormat`, `fileSizeBytes`, `lyrics`), relationships (`albumId`, `genreId`), and media (`audioUrl`, `previewUrl`, `waveformUrl`, `coverUrl`). Supports an exact Many-to-Many mapping to `artists`.

## Organizational Entities
- **Playlist**: Supports types (`MANUAL`, `EDITORIAL`, `SMART`), status, JSON tags.
- **PlaylistSong**: Custom junction table capturing explicit `position` for drag-and-drop ordering, plus `customCrossfadeMs`.

## CMS Entities
- **HomepageSection**: Configures UI blocks (`HERO_BANNER`, `GRID`) and dynamic `order`.
- **HomepageItem**: Maps directly to internal reference UUIDs (ALBUM, SONG) allowing custom banner overrides.

## System & Analytics
- **MediaUpload**: Tracks chunked upload sessions (`progress`, `status`, `mimeType`, `errorLog`).
- **SearchQuery**: Tracks global unified search analytics (`term`, `resultCount`) to identify top trends and missing content.
- **AuditLog**: Generic logging tracking `action`, `entityName`, `entityId`, `adminUsername`, `changes` (JSONB).
