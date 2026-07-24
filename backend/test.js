const Database = require('better-sqlite3');
const db = new Database('neo_db.sqlite');
try {
  const users = db.prepare('SELECT id, username, passwordHash FROM users').all();
  console.log('Users in DB:', users);
} catch (e) {
  console.error('Error querying users:', e);
}
