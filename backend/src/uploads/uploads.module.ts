import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MediaUpload } from '../entities/media-upload.entity';
import { UploadsService } from './uploads.service';
import { UploadsController } from './uploads.controller';

@Module({
  imports: [TypeOrmModule.forFeature([MediaUpload])],
  providers: [UploadsService],
  controllers: [UploadsController],
})
export class UploadsModule {}
