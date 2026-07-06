import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  ManyToMany,
  JoinTable,
  DeleteDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Album } from './album.entity';
import { Artist } from './artist.entity';
import { Genre } from './genre.entity';

export enum SongStatus {
  DRAFT = 'DRAFT',
  PROCESSING = 'PROCESSING',
  SCHEDULED = 'SCHEDULED',
  PUBLISHED = 'PUBLISHED',
  HIDDEN = 'HIDDEN',
  ARCHIVED = 'ARCHIVED',
}

@Entity('songs')
export class Song {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ nullable: true })
  audioUrl: string;

  @Column({ nullable: true })
  coverUrl: string;

  @Column({ nullable: true })
  previewUrl: string;

  @Column({ type: 'jsonb', nullable: true })
  waveformUrl: any;

  @Column({ nullable: true })
  language: string;

  @Column({ default: false })
  isExplicit: boolean;

  @Column({ type: 'text', nullable: true })
  lyrics: string;

  @Column({ nullable: true })
  composer: string;

  @Column({ nullable: true })
  producer: string;

  @Column({ nullable: true })
  isrc: string;

  @Column({ type: 'float', nullable: true })
  durationMs: number;

  @Column({ type: 'int', nullable: true })
  bitrate: number;

  @Column({ type: 'int', nullable: true })
  sampleRate: number;

  @Column({ nullable: true })
  audioFormat: string;

  @Column({ type: 'int', nullable: true })
  fileSizeBytes: number;

  @Column({ type: 'int', nullable: true })
  trackNumber: number;

  @Column({ type: 'int', nullable: true })
  discNumber: number;

  @Column({ type: 'date', nullable: true })
  releaseDate: string;

  @Column({ type: 'varchar', enum: SongStatus, default: SongStatus.DRAFT })
  status: SongStatus;

  @ManyToOne(() => Album, (album) => album.songs, { nullable: true })
  album: Album;

  @ManyToOne(() => Genre, (genre) => genre.songs, { nullable: true })
  genre: Genre;

  @ManyToMany(() => Artist, (artist) => artist.songs)
  @JoinTable({ name: 'song_artists' })
  artists: Artist[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
