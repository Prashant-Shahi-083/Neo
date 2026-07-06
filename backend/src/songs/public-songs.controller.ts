import {
  Controller,
  Get,
  Param,
  Headers,
  Res,
  Req,
  NotFoundException,
} from '@nestjs/common';
import type { Response, Request } from 'express';
import { SongsService } from './songs.service';
import * as fs from 'fs';
import * as path from 'path';

@Controller('api/v1/songs')
export class PublicSongsController {
  constructor(private readonly songsService: SongsService) {}

  @Get(':id/stream')
  async streamAudio(
    @Param('id') id: string,
    @Headers('range') range: string,
    @Req() req: Request,
    @Res() res: Response,
  ) {
    const song = await this.songsService.findOne(id);
    if (!song || !song.audioUrl) {
      throw new NotFoundException('Song audio not found');
    }

    // audioUrl is typically relative like /uploads/songs/filename.mp3
    // We need to resolve it to an absolute path on disk.
    // Assuming backend root is the working directory where 'uploads' folder is.
    const audioPath = path.join(process.cwd(), song.audioUrl);

    if (!fs.existsSync(audioPath)) {
      throw new NotFoundException('Audio file is missing on disk');
    }

    const stat = fs.statSync(audioPath);
    const fileSize = stat.size;

    if (range) {
      const parts = range.replace(/bytes=/, '').split('-');
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = end - start + 1;
      const file = fs.createReadStream(audioPath, { start, end });

      const head = {
        'Content-Range': `bytes ${start}-${end}/${fileSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunksize,
        'Content-Type': 'audio/mpeg',
      };

      res.writeHead(206, head);
      file.pipe(res);
    } else {
      const head = {
        'Content-Length': fileSize,
        'Content-Type': 'audio/mpeg',
      };
      res.writeHead(200, head);
      fs.createReadStream(audioPath).pipe(res);
    }
  }
}
