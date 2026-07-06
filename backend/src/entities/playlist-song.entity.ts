import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Playlist } from './playlist.entity';
import { Song } from './song.entity';

@Entity('playlist_songs')
export class PlaylistSong {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'int' })
  position: number;

  @Column({ type: 'int', nullable: true })
  customCrossfadeMs: number;

  @Column({ type: 'jsonb', nullable: true })
  localMetadata: any;

  @ManyToOne(() => Playlist, (playlist) => playlist.playlistSongs, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'playlistId' })
  playlist: Playlist;

  @ManyToOne(() => Song, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'songId' })
  song: Song;

  @CreateDateColumn()
  addedAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
