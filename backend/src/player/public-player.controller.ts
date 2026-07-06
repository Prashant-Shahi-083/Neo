import { Controller, Get, Param } from '@nestjs/common';
import { PlayerService } from './player.service';

@Controller('api/v1/player')
export class PublicPlayerController {
  constructor(private readonly playerService: PlayerService) {}

  @Get('metadata/:songId')
  async getMetadata(@Param('songId') songId: string) {
    return this.playerService.getPlaybackMetadata(songId);
  }
}
