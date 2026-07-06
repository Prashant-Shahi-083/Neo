import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import {
  Controller,
  UseGuards as ExistingUseGuards,
  Get,
  Post,
  Body,
  Param,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  Request,
} from '@nestjs/common';
import { UploadsService } from './uploads.service';
import { InitUploadDto } from './dto/init-upload.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import * as os from 'os';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/uploads')
export class UploadsController {
  constructor(private readonly uploadsService: UploadsService) {}

  @Get()
  findAll() {
    return this.uploadsService.findAll();
  }

  @Post('init')
  initUpload(@Body() dto: InitUploadDto, @Request() req) {
    return this.uploadsService.initUpload(
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Post(':sessionId/chunk')
  @UseInterceptors(
    FileInterceptor('chunk', {
      storage: diskStorage({
        destination: os.tmpdir(), // temp location before moving to session dir
        filename: (req, file, cb) => {
          cb(null, `chunk-${Date.now()}`);
        },
      }),
    }),
  )
  uploadChunk(
    @Param('sessionId') sessionId: string,
    @Body('chunkIndex') chunkIndex: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) throw new BadRequestException('No chunk provided');
    if (chunkIndex === undefined)
      throw new BadRequestException('chunkIndex required');
    return this.uploadsService.uploadChunk(
      sessionId,
      parseInt(chunkIndex),
      file,
    );
  }

  @Post(':sessionId/complete')
  completeUpload(
    @Param('sessionId') sessionId: string,
    @Body('totalChunks') totalChunks: number,
  ) {
    if (!totalChunks) throw new BadRequestException('totalChunks required');
    return this.uploadsService.completeUpload(sessionId, totalChunks);
  }
}
