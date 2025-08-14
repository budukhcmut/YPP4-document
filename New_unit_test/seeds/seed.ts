import { DataSource } from 'typeorm';
import { insertSampleData } from './02_insert_script.seed';
import { createTables } from './01_create_script.seed';

export async function runAllSeeds(dataSource: DataSource): Promise<void> {
  console.log('>>> Starting database seeding...');

  try {
    await createTables(dataSource);
    await insertSampleData(dataSource);
    console.log('>>> All seeds completed successfully!');
  } catch (error) {
    console.error('>>> Error during seeding: ', error);
    throw error;
  }
}

export async function seedDatabase(): Promise<void> {
  const dataSource = new DataSource({
    type: 'sqlite',
    database: 'database.sqlite',
    entities: [__dirname + '/../entities/*.entity{.ts,.js}'],
    synchronize: true,
    logging: false,
  });

  try {
    await dataSource.initialize();
    console.log('>>> Database connected');

    await runAllSeeds(dataSource);

    await dataSource.destroy();
    console.log('>>> Database connection closed');
  } catch (error) {
    console.error('>>> Seeding failed: ', error);
    process.exit(1);
  }
}

if (require.main === module) {
  void seedDatabase();
}