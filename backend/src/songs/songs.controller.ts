import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { SongsService } from './songs.service';
import { CreateSongDto } from './dto/create-song.dto';
import { UpdateSongDto } from './dto/update-song.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/songs')
export class SongsController {
  constructor(private readonly songsService: SongsService) {}

  @Get('metadata/form-data')
  getMetadataForm() {
    return this.songsService.getMetadataForm();
  }

  @Get()
  findAll(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('search') search: string = '',
  ) {
    return this.songsService.findAll(+page, +limit, search);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.songsService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateSongDto, @Request() req) {
    return this.songsService.create(dto, req.user?.username || 'System Admin');
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdateSongDto, @Request() req) {
    return this.songsService.update(
      id,
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.songsService.remove(id, req.user?.username || 'System Admin');
  }

  @Post(':id/cover')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/covers',
        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, uniqueSuffix + extname(file.originalname));
        },
      }),
    }),
  )
  uploadCover(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req,
  ) {
    if (!file) throw new BadRequestException('No file provided');
    const fileUrl = `/uploads/covers/${file.filename}`;
    return this.songsService.uploadCover(
      id,
      fileUrl,
      req.user?.username || 'System Admin',
    );
  }

  @Post(':id/audio')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/songs',
        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, uniqueSuffix + extname(file.originalname));
        },
      }),
    }),
  )
  uploadAudio(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req,
  ) {
    if (!file) throw new BadRequestException('No file provided');
    return this.songsService.uploadAudio(
      id,
      file,
      req.user?.username || 'System Admin',
    );
  }
}
