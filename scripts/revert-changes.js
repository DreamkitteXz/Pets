const fs = require('fs');
const path = require('path');

const dirsToDelete = [
  './src/features',
  './src/context',
  './src/components/layout/Header',
  './src/components/layout/Sidebar',
];

// Delete directories that were created
dirsToDelete.forEach(dir => {
  const fullPath = path.join(__dirname, '..', dir);
  if (fs.existsSync(fullPath)) {
    fs.rmdirSync(fullPath, { recursive: true });
    console.log(`Deleted directory: ${dir}`);
  }
});
