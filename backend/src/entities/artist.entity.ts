import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  OneToMany,
  DeleteDateColumn,
  UpdateDateColumn,
  ManyToMany,
} from 'typeorm';
import { Album } from './album.entity';
import { Song } from './song.entity';

@Entity('artists')
export class Artist {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({ nullable: true })
  photoUrl: string;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ default: true })
  isActive: boolean;

  @OneToMany(() => Album, (album) => album.artist)
  albums: Album[];

  @ManyToMany(() => Song, (song) => song.artists)
  songs: Song[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
