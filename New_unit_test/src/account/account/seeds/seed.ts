import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

async function runSeed() {
  const dataSource = new DataSource({
    type: 'sqlite',
    database: 'database.sqlite',
    synchronize: false,
  });

  await dataSource.initialize();

  const seedsDir = path.join(__dirname);
  const files = fs.readdirSync(seedsDir)
    .filter(f => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(seedsDir, file), 'utf8');
    await dataSource.query(sql);
    console.log(`✅ Ran seed: ${file}`);
  }

  await dataSource.destroy();
}

runSeed().catch(err => {
  console.error(err);
  process.exit(1);
});
