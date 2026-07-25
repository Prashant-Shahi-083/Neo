import 'dotenv/config';
import { DataSource, DataSourceOptions } from 'typeorm';
import * as path from 'path';

const dbType = process.env.DB_TYPE || 'better-sqlite3';
let dbUrl = process.env.DATABASE_URL || '';

// Automatically convert Supabase session pooler on port 5432 to Transaction Pooler (port 6543)
if (dbUrl.includes('.pooler.supabase.com:5432')) {
  dbUrl = dbUrl.replace(':5432', ':6543');
  if (!dbUrl.includes('pgbouncer=true')) {
    dbUrl += (dbUrl.includes('?') ? '&' : '?') + 'pgbouncer=true';
  }
}

export const dataSourceOptions: DataSourceOptions =
  dbType === 'postgres'
    ? {
        type: 'postgres',
        // Rely strictly on url property without conflicting host, port, username, password, or database fallbacks
        url: dbUrl,
        synchronize: false, // In CLI / migrations mode, synchronize should be false
        logging: true,
        entities: [path.join(__dirname, '/**/*.entity{.ts,.js}')],
        migrations: [path.join(__dirname, '/migrations/*{.ts,.js}')],
        // Required for external Supabase / cloud connections
        ssl: { rejectUnauthorized: false },
        extra: {
          max: 20,
          connectionTimeoutMillis: 10000,
        },
      }
    : {
        type: 'better-sqlite3',
        database: process.env.DB_DATABASE || 'neo_db.sqlite',
        synchronize: false,
        logging: true,
        entities: [path.join(__dirname, '/**/*.entity{.ts,.js}')],
        migrations: [path.join(__dirname, '/migrations/*{.ts,.js}')],
      };

const AppDataSource = new DataSource(dataSourceOptions);
export default AppDataSource;
