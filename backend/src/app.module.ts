import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { TypeOrmModule, TypeOrmModuleOptions } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { AuditLogsModule } from './audit-logs/audit-logs.module';
import { ArtistsModule } from './artists/artists.module';
import { AlbumsModule } from './albums/albums.module';
import { SongsModule } from './songs/songs.module';
import { UploadsModule } from './uploads/uploads.module';
import { PlaylistsModule } from './playlists/playlists.module';
import { HomepageModule } from './homepage/homepage.module';
import { SearchModule } from './search/search.module';
import { RecommendationsModule } from './recommendations/recommendations.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { SystemModule } from './system/system.module';
import { ApiKeysModule } from './api-keys/api-keys.module';
import { PlayerModule } from './player/player.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 100,
      },
    ]),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService): TypeOrmModuleOptions => {
        const dbType = configService.get<string>('DB_TYPE', 'better-sqlite3');
        if (dbType === 'postgres') {
          let dbUrl = configService.get<string>('DATABASE_URL') || '';
          // If using Supabase session pooler on port 5432, automatically convert to Transaction Pooler (port 6543) for IPv4 cloud compatibility
          if (dbUrl.includes('.pooler.supabase.com:5432')) {
            console.warn('[Supabase Notice] Automatically converting Supabase Session Pooler (port 5432) to Transaction Pooler (port 6543) for cloud IPv4 compatibility.');
            dbUrl = dbUrl.replace(':5432', ':6543');
            if (!dbUrl.includes('pgbouncer=true')) {
              dbUrl += (dbUrl.includes('?') ? '&' : '?') + 'pgbouncer=true';
            }
          } else if (dbUrl.includes(':5432')) {
            console.warn('[Supabase Warning] Connecting to direct PostgreSQL endpoint on port 5432 may fail with ENETUNREACH on Render without IPv6 routing. Please use the Supabase Transaction Pooler connection string on port 6543.');
          }
          // Rely strictly on url property without conflicting host, port, username, password, or database fallbacks
          // This prevents full usernames like postgres.[project-id] from being overwritten or truncated at runtime
          return {
            type: 'postgres',
            url: dbUrl,
            autoLoadEntities: true,
            synchronize: true, // Auto-sync for MVP phase
            ssl: { rejectUnauthorized: false }, // Required for Supabase and cloud managed DBs
            extra: {
              max: 20, // Connection pool limit for Supabase / cloud PostgreSQL
              connectionTimeoutMillis: 10000,
            },
          } as any as TypeOrmModuleOptions;
        }
        return {
          type: 'better-sqlite3',
          database: configService.get<string>('DB_DATABASE', 'neo_db.sqlite'),
          autoLoadEntities: true,
          synchronize: true,
        } as any as TypeOrmModuleOptions;
      },
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    AuditLogsModule,
    ArtistsModule,
    AlbumsModule,
    SongsModule,
    UploadsModule,
    PlaylistsModule,
    HomepageModule,
    SearchModule,
    RecommendationsModule,
    AnalyticsModule,
    SystemModule,
    ApiKeysModule,
    PlayerModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
