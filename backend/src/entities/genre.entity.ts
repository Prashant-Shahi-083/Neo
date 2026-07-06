import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { Album } from './album.entity';
import { Song } from './song.entity';

@Entity('genres')
export class Genre {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @OneToMany(() => Album, (album) => album.genre)
  albums: Album[];

  @OneToMany(() => Song, (song) => song.genre)
  songs: Song[];

  @CreateDateColumn()
  createdAt: Date;
}
