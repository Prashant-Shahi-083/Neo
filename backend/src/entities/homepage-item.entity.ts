import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { HomepageSection } from './homepage-section.entity';

export enum ReferenceType {
  ALBUM = 'ALBUM',
  PLAYLIST = 'PLAYLIST',
  ARTIST = 'ARTIST',
  SONG = 'SONG',
  EXTERNAL_LINK = 'EXTERNAL_LINK',
}

@Entity('homepage_items')
export class HomepageItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'int', default: 0 })
  order: number;

  @Column({ type: 'varchar', enum: ReferenceType })
  referenceType: ReferenceType;

  @Column()
  referenceId: string; // The UUID of the referenced Album/Playlist/Artist/Song

  @Column({ nullable: true })
  customTitle: string; // Override the title

  @Column({ nullable: true })
  customSubtitle: string; // Override subtitle

  @Column({ nullable: true })
  customImageUrl: string; // Override banner/cover image

  @ManyToOne(() => HomepageSection, (section) => section.items, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'sectionId' })
  section: HomepageSection;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
