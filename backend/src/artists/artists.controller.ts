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
import { ArtistsService } from './artists.service';
import { CreateArtistDto } from './dto/create-artist.dto';
import { UpdateArtistDto } from './dto/update-artist.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/artists')
export class ArtistsController {
  constructor(private readonly artistsService: ArtistsService) {}

  @Get()
  findAll(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('search') search: string = '',
  ) {
    return this.artistsService.findAll(+page, +limit, search);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.artistsService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateArtistDto, @Request() req) {
    return this.artistsService.create(
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateArtistDto,
    @Request() req,
  ) {
    return this.artistsService.update(
      id,
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.artistsService.remove(id, req.user?.username || 'System Admin');
  }

  @Post(':id/image')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/artists',
        filename: (req, file, cb) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, uniqueSuffix + extname(file.originalname));
        },
      }),
    }),
  )
  uploadImage(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }
    const fileUrl = `/uploads/artists/${file.filename}`;
    return this.artistsService.uploadImage(
      id,
      fileUrl,
      req.user?.username || 'System Admin',
    );
  }
}
