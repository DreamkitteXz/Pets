const fs = require('fs');
const path = require('path');

const filesToDelete = [
  './src/components/App/index.jsx',
  './src/components/App/index.test.js',
  './src/components/pages/Auth/AuthCheck.jsx',
  './src/components/pages/Auth/ProfileCompletionCheck.jsx',
  './src/components/shared/Layout/Layout.jsx',
  './src/PerfilButton.jsx',
];

filesToDelete.forEach(file => {
  const fullPath = path.join(__dirname, '..', file);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
    console.log(`Deleted: ${file}`);
  }
});

// Remove empty directories
const dirsToCheck = [
  'src/components/pages',
  'src/components/App',
  'src/components/shared/Layout',
];

dirsToCheck.forEach(dir => {
  const fullPath = path.join(__dirname, '..', dir);
  if (fs.existsSync(fullPath) && fs.readdirSync(fullPath).length === 0) {
    fs.rmdirSync(fullPath);
    console.log(`Removed empty directory: ${dir}`);
  }
});
