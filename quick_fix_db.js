import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const routesDir = path.join(__dirname, 'routes');

// Get all JS files in routes directory
const routeFiles = fs.readdirSync(routesDir).filter(file => file.endsWith('.js'));

console.log('🔧 Quick fixing database calls in route files...');

routeFiles.forEach(file => {
  const filePath = path.join(routesDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Replace pool import with db import
  if (content.includes("import pool from '../config/db.js'")) {
    content = content.replace(
      "import pool from '../config/db.js'",
      "import db from '../utils/database.js'"
    );
    console.log(`✅ Updated import in ${file}`);
  }
  
  // Replace all pool.execute with db.execute
  const poolExecuteCount = (content.match(/pool\.execute/g) || []).length;
  if (poolExecuteCount > 0) {
    content = content.replace(/pool\.execute/g, 'db.execute');
    console.log(`✅ Replaced ${poolExecuteCount} pool.execute calls in ${file}`);
  }
  
  // Write back to file
  fs.writeFileSync(filePath, content);
});

console.log('🎉 All route files updated!');
console.log('📝 Now commit and push these changes:');
console.log('git add .');
console.log('git commit -m "Replace pool.execute with db.execute for PostgreSQL compatibility"');
console.log('git push origin main');
