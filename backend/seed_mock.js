const Database = require('better-sqlite3');
const crypto = require('crypto');

const db = new Database('neo_db.sqlite');

console.log('Starting seed process...');

// Clear existing tables (except users and system settings)
db.exec(`
  DELETE FROM homepage_items;
  DELETE FROM homepage_sections;
  DELETE FROM song_artists;
  DELETE FROM songs;
  DELETE FROM artists;
`);

console.log('Cleared tables.');

// Generate random UUID
const uuid = () => crypto.randomUUID();

// Date strings
const now = new Date().toISOString();

// Cover URLs
const covers = [
  'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=500&q=80',
  'https://images.unsplash.com/photo-1528642474498-1af0c17fd8c3?auto=format&fit=crop&w=500&q=80',
  'https://images.unsplash.com/photo-1490226466986-e26090ed84c7?auto=format&fit=crop&w=500&q=80',
  'https://images.unsplash.com/photo-1550505096-7cfae4f71120?auto=format&fit=crop&w=500&q=80',
];

// Insert Artists
const insertArtist = db.prepare('INSERT INTO artists (id, name, isVerified, isActive, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?)');
const weekndId = uuid();
const siaId = uuid();
const imagineDragonsId = uuid();

insertArtist.run(weekndId, 'The Weeknd', 1, 1, now, now);
insertArtist.run(siaId, 'Sia', 1, 1, now, now);
insertArtist.run(imagineDragonsId, 'Imagine Dragons', 1, 1, now, now);

// Insert Songs
const insertSong = db.prepare(`
  INSERT INTO songs (id, title, coverUrl, durationMs, status, isExplicit, audioUrl, createdAt, updatedAt)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
`);
const insertSongArtist = db.prepare('INSERT INTO song_artists ("songsId", "artistsId") VALUES (?, ?)');

const sampleMp3 = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

const songs = [
  { id: uuid(), title: 'Blinding Lights', artistId: weekndId, cover: covers[0], durationMs: 200000 },
  { id: uuid(), title: 'Unstoppable', artistId: siaId, cover: covers[1], durationMs: 217000 },
  { id: uuid(), title: 'Starboy', artistId: weekndId, cover: covers[2], durationMs: 230000 },
  { id: uuid(), title: 'Bones', artistId: imagineDragonsId, cover: covers[3], durationMs: 165000 },
  { id: uuid(), title: 'After Hours', artistId: weekndId, cover: covers[0], durationMs: 361000 },
  { id: uuid(), title: 'Chandelier', artistId: siaId, cover: covers[1], durationMs: 216000 },
  { id: uuid(), title: 'Believer', artistId: imagineDragonsId, cover: covers[2], durationMs: 204000 },
  { id: uuid(), title: 'Save Your Tears', artistId: weekndId, cover: covers[3], durationMs: 215000 },
];

for (const s of songs) {
  insertSong.run(s.id, s.title, s.cover, s.durationMs, 'PUBLISHED', 0, sampleMp3, now, now);
  insertSongArtist.run(s.id, s.artistId);
}

// Insert Homepage Sections
const insertSection = db.prepare('INSERT INTO homepage_sections (id, title, type, "order", isActive, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)');
const insertItem = db.prepare('INSERT INTO homepage_items (id, "order", referenceType, referenceId, sectionId, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)');

const recentlyPlayedId = uuid();
const madeForYouId = uuid();

insertSection.run(recentlyPlayedId, 'Recently Played', 'HORIZONTAL_LIST', 1, 1, now, now);
insertSection.run(madeForYouId, 'Made For You', 'HORIZONTAL_LIST', 2, 1, now, now);

// Link items to sections
const recentlyPlayedSongs = songs.slice(0, 4);
const madeForYouSongs = songs.slice(4, 8);

recentlyPlayedSongs.forEach((s, idx) => {
  insertItem.run(uuid(), idx + 1, 'SONG', s.id, recentlyPlayedId, now, now);
});

madeForYouSongs.forEach((s, idx) => {
  insertItem.run(uuid(), idx + 1, 'SONG', s.id, madeForYouId, now, now);
});

console.log('Seed completed successfully!');
db.close();
