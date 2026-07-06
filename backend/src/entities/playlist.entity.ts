import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  DeleteDateColumn,
} from 'typeorm';
import { PlaylistSong } from './playlist-song.entity';

export enum PlaylistType {
  MANUAL = 'MANUAL',
  EDITORIAL = 'EDITORIAL',
  SMART = 'SMART',
  FEATURED = 'FEATURED',
}

export enum PlaylistStatus {
  PUBLIC = 'PUBLIC',
  PRIVATE = 'PRIVATE',
  UNLISTED = 'UNLISTED',
  ARCHIVED = 'ARCHIVED',
}

@Entity('playlists')
export class Playlist {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  coverUrl: string;

  @Column({ type: 'varchar', enum: PlaylistType, default: PlaylistType.MANUAL })
  type: PlaylistType;

  @Column({
    type: 'varchar',
    enum: PlaylistStatus,
    default: PlaylistStatus.PRIVATE,
  })
  status: PlaylistStatus;

  @Column({ type: 'jsonb', nullable: true })
  tags: string[];

  @Column({ type: 'jsonb', nullable: true })
  categories: string[];

  @Column({
    type: 'jsonb',
    nullable: true,
    default: { plays: 0, likes: 0, shares: 0 },
  })
  statistics: any;

  @Column()
  adminUsername: string;

  @OneToMany(() => PlaylistSong, (ps) => ps.playlist, { cascade: true })
  playlistSongs: PlaylistSong[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
