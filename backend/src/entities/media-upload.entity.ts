import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum UploadStatus {
  PENDING = 'PENDING',
  UPLOADING = 'UPLOADING',
  PROCESSING = 'PROCESSING',
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
}

@Entity('media_uploads')
export class MediaUpload {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  originalFilename: string;

  @Column({ type: 'int' })
  fileSizeBytes: number;

  @Column()
  mimeType: string;

  @Column({
    type: 'varchar',
    enum: UploadStatus,
    default: UploadStatus.PENDING,
  })
  status: UploadStatus;

  @Column({ type: 'float', default: 0 })
  progress: number;

  @Column({ nullable: true })
  fileUrl: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: any;

  @Column({ type: 'text', nullable: true })
  errorLog: string;

  @Column()
  adminUsername: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
