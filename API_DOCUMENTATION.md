# NEO Platform API Documentation

## Base URL
`/api/v1`

## Modules

### 1. Unified Search (`/search`)
- `GET /search?q={query}`: Returns top 10 matched Songs, Artists, Albums, and Playlists.
- `GET /admin/search/analytics/top`: Returns high-frequency search terms.
- `GET /admin/search/analytics/zero-results`: Returns high-frequency missing terms.
- `GET /admin/search/analytics/recent`: Live stream of query logs.

### 2. Homepage CMS (`/admin/homepage`)
- `GET /`: Returns fully populated CMS layout tree.
- `POST /sections`: Create new layout block.
- `PUT /sections/reorder`: Bulk update section order.
- `POST /sections/:id/items`: Target an entity (Album/Playlist) for display.
- `PUT /sections/:id/items/reorder`: Bulk update item order.

### 3. Playlists (`/admin/playlists`)
- `GET /`: Standard CRUD search/paginate.
- `POST /:id/songs`: Map a song to a playlist.
- `PUT /:id/songs/reorder`: Persist a drag-and-drop order event by passing `orderedSongIds` array.

### 4. Upload Center (`/admin/uploads`)
- `POST /init`: Start a chunked session.
- `POST /:sessionId/chunk`: Upload a binary slice (FormData `chunk`).
- `POST /:sessionId/complete`: Request final assembly.

### 5. Media & Content
Standard REST endpoints (`GET`, `POST`, `PUT`, `DELETE`) with specific overrides for Multer integration (`/:id/cover`, `/:id/audio`).
