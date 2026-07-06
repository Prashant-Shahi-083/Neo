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
import { ApiKey } from './entities/api-key.entity';
import { SystemSetting } from './entities/system-setting.entity';

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
