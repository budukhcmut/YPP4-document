import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'UserFile' })
export class UserFile {
   @PrimaryGeneratedColumn()
  FileId: number;

  @Column({ type: 'integer', nullable: true })
  FolderId?: number | null;

  @Column({ type: 'integer' })
  OwnerId: number;

  @Column({ type: 'bigint', nullable: true })
  Size?: number | null;

  @Column({ type: 'text' })
  UserFileName: string;

  @Column({ type: 'text', nullable: true })
  UserFilePath?: string | null;

  @Column({ type: 'text', nullable: true })
  UserFileThumbNailImg?: string | null;

  @Column({ type: 'integer', nullable: true })
  FileTypeId?: number | null;

  @Column({ type: 'datetime', nullable: true })
  ModifiedDate?: Date | null;

  @Column({ type: 'text', nullable: true })
  UserFileStatus?: string | null;

  @Column({ type: 'datetime', default: () => "CURRENT_TIMESTAMP" })
  CreatedAt: Date;
}