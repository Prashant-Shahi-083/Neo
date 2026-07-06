const fs = require('fs');
const path = require('path');

const files = [
  'album.entity.ts',
  'homepage-item.entity.ts',
  'homepage-section.entity.ts',
  'media-upload.entity.ts',
  'playlist.entity.ts',
  'user.entity.ts',
  'song.entity.ts'
];

files.forEach(f => {
  const filePath = path.join(__dirname, 'src', 'entities', f);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    content = content.replace(/type:\s*'enum'/g, "type: 'varchar'");
    fs.writeFileSync(filePath, content);
    console.log('Fixed', f);
  }
});
