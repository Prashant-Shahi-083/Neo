# API Contract Document

This document defines the strict data transfer contracts between the NestJS backend and the Flutter client. The backend MUST return data matching these DTO structures precisely, and the Flutter client's `fromJson` factory methods MUST consume them accurately.

## 1. Authentication & User Profile
**Endpoint**: `GET /api/v1/auth/me`
**Backend DTO**: `UserProfileDto`
**Flutter Model**: `UserProfile`

```json
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "avatarUrl": "string",
  "accountType": "string",
  "joinDate": "ISO-8601 DateTime",
  "stats": {
    "totalListeningHours": 0,
    "totalTracksPlayed": 0,
    "topGenres": ["string"]
  }
}
```

## 2. Songs
**Backend DTO**: `SongDto`
**Flutter Model**: `Song`

```json
{
  "id": "uuid",
  "title": "string",
  "audioUrl": "string",
  "coverUrl": "string",
  "durationMs": 0,
  "artists": [
    { "name": "string" }
  ],
  "album": {
    "title": "string"
  }
}
```

## 3. Playlists
**Endpoint**: `GET /api/v1/playlists/:id`
**Backend DTO**: `PlaylistDto`
**Flutter Model**: `Playlist`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "coverUrl": "string"
}
```

## 4. Homepage CMS
**Endpoint**: `GET /api/v1/homepage`
**Backend DTO**: `HomepageDto`
**Flutter Model**: Handled in `HomeRepository`

```json
{
  "sections": [
    {
      "id": "uuid",
      "title": "string",
      "type": "SONGS | PLAYLISTS",
      "items": [ /* Array of SongDto or PlaylistDto */ ]
    }
  ]
}
```

## 5. Search Results
**Endpoint**: `GET /api/v1/search?q=query`
**Backend DTO**: `SearchResultDto`
**Flutter Model**: Handled in `SearchRepository`

```json
{
  "songs": [ /* Array of SongDto */ ],
  "playlists": [ /* Array of PlaylistDto */ ],
  "albums": [ /* Array of AlbumDto */ ],
  "artists": [ /* Array of ArtistDto */ ]
}
```
