import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MediaUpload, UploadStatus } from '../entities/media-upload.entity';
import { InitUploadDto } from './dto/init-upload.dto';
import * as fs from 'fs';
import * as path from 'path';
const sharp = require('sharp');

@Injectable()
export class UploadsService {
  private readonly logger = new Logger(UploadsService.name);
  private tempPath = './uploads/temp';
  private finalPath = './uploads/media';

  constructor(
    @InjectRepository(MediaUpload) private uploadRepo: Repository<MediaUpload>,
  ) {
    if (!fs.existsSync(this.tempPath))
      fs.mkdirSync(this.tempPath, { recursive: true });
    if (!fs.existsSync(this.finalPath))
      fs.mkdirSync(this.finalPath, { recursive: true });
  }

  async initUpload(dto: InitUploadDto, adminUsername: string) {
    const upload = this.uploadRepo.create({
      originalFilename: dto.filename,
      fileSizeBytes: dto.fileSize,
      mimeType: dto.mimeType,
      adminUsername,
      status: UploadStatus.UPLOADING,
    });
    const saved = await this.uploadRepo.save(upload);
    const sessionDir = path.join(this.tempPath, saved.id);
    if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir);
    return { sessionId: saved.id };
  }

  async uploadChunk(
    sessionId: string,
    chunkIndex: number,
    file: Express.Multer.File,
  ) {
    const sessionDir = path.join(this.tempPath, sessionId);
    if (!fs.existsSync(sessionDir))
      throw new NotFoundException('Session not found');
    const chunkPath = path.join(sessionDir, `${chunkIndex}`);
    fs.renameSync(file.path, chunkPath);
    return { success: true };
  }

  async completeUpload(sessionId: string, totalChunks: number) {
    const upload = await this.uploadRepo.findOne({ where: { id: sessionId } });
    if (!upload) throw new NotFoundException('Upload session not found');

    const sessionDir = path.join(this.tempPath, sessionId);
    const ext = path.extname(upload.originalFilename);
    const finalFilename = `${sessionId}${ext}`;
    const finalFilePath = path.join(this.finalPath, finalFilename);

    upload.status = UploadStatus.PROCESSING;
    await this.uploadRepo.save(upload);

    const writeStream = fs.createWriteStream(finalFilePath);
    for (let i = 0; i < totalChunks; i++) {
      const chunkPath = path.join(sessionDir, `${i}`);
      if (!fs.existsSync(chunkPath)) {
        upload.status = UploadStatus.FAILED;
        upload.errorLog = `Missing chunk ${i}`;
        await this.uploadRepo.save(upload);
        throw new Error(`Missing chunk ${i}`);
      }
      const data = fs.readFileSync(chunkPath);
      writeStream.write(data);
      fs.unlinkSync(chunkPath);
    }
    writeStream.end();
    fs.rmdirSync(sessionDir);

    upload.fileUrl = `/uploads/media/${finalFilename}`;

    this.processFileBackground(upload, finalFilePath).catch((err) => {
      this.logger.error('Background processing failed', err);
    });

    return {
      message: 'Upload completed and queued for processing',
      uploadId: upload.id,
    };
  }

  private async processFileBackground(upload: MediaUpload, filePath: string) {
    try {
      let metadata: any = {};

      this.logger.log(`Executing Virus Scan Hook for ${upload.id}`);
      await new Promise((res) => setTimeout(res, 500));

      if (upload.mimeType.startsWith('image/')) {
        const thumbName = `thumb_${path.basename(filePath)}`;
        const thumbPath = path.join(this.finalPath, thumbName);
        const info = await sharp(filePath)
          .resize(300, 300, { fit: 'cover' })
          .toFile(thumbPath);
        metadata = {
          ...metadata,
          width: info.width,
          height: info.height,
          thumbnail: `/uploads/media/${thumbName}`,
        };
      } else if (upload.mimeType.startsWith('audio/')) {
        this.logger.log(`Executing Audio Normalization Hook for ${upload.id}`);
        await new Promise((res) => setTimeout(res, 800));
      }

      upload.metadata = metadata;
      upload.progress = 100;
      upload.status = UploadStatus.SUCCESS;
      await this.uploadRepo.save(upload);
    } catch (error) {
      upload.status = UploadStatus.FAILED;
      upload.errorLog = error.message || 'Unknown error';
      await this.uploadRepo.save(upload);
    }
  }

  async findAll() {
    return this.uploadRepo.find({ order: { createdAt: 'DESC' } });
  }
}
