const fs = require('fs');
const path = require('path');

function scanDirectory(dir) {
  let files = [];
  const items = fs.readdirSync(dir);
  
  items.forEach(item => {
    const fullPath = path.join(dir, item);
    if (fs.statSync(fullPath).isDirectory()) {
      if (!item.includes('node_modules') && !item.includes('.git')) {
        files = files.concat(scanDirectory(fullPath));
      }
    } else {
      files.push(fullPath);
    }
  });
  
  return files;
}

const projectFiles = scanDirectory('../');
console.log('Project Structure:');
projectFiles.forEach(file => console.log(file));
