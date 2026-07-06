import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  DeleteDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Artist } from './artist.entity';
import { Song } from './song.entity';
import { Genre } from './genre.entity';

export enum AlbumStatus {
  DRAFT = 'DRAFT',
  SCHEDULED = 'SCHEDULED',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED',
}

@Entity('albums')
export class Album {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  coverUrl: string;

  @Column({ type: 'date', nullable: true })
  releaseDate: string;

  @Column({ type: 'varchar', enum: AlbumStatus, default: AlbumStatus.DRAFT })
  status: AlbumStatus;

  @ManyToOne(() => Artist, (artist) => artist.albums)
  artist: Artist;

  @ManyToOne(() => Genre, (genre) => genre.albums, { nullable: true })
  genre: Genre;

  @OneToMany(() => Song, (song) => song.album)
  songs: Song[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
