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
import { AlbumsService } from './albums.service';
import { CreateAlbumDto } from './dto/create-album.dto';
import { UpdateAlbumDto } from './dto/update-album.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/albums')
export class AlbumsController {
  constructor(private readonly albumsService: AlbumsService) {}

  @Get('metadata/form-data')
  getMetadataForm() {
    return this.albumsService.getMetadataForm();
  }

  @Get()
  findAll(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('search') search: string = '',
  ) {
    return this.albumsService.findAll(+page, +limit, search);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.albumsService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateAlbumDto, @Request() req) {
    return this.albumsService.create(dto, req.user?.username || 'System Admin');
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAlbumDto, @Request() req) {
    return this.albumsService.update(
      id,
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.albumsService.remove(id, req.user?.username || 'System Admin');
  }

  @Post(':id/cover')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/albums',
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
    if (!file) {
      throw new BadRequestException('No file provided');
    }
    const fileUrl = `/uploads/albums/${file.filename}`;
    return this.albumsService.uploadCover(
      id,
      fileUrl,
      req.user?.username || 'System Admin',
    );
  }
}
