import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PublicPlayerController } from './public-player.controller';
import { PlayerService } from './player.service';
import { Song } from '../entities/song.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Song])],
  controllers: [PublicPlayerController],
  providers: [PlayerService],
})
export class PlayerModule {}
