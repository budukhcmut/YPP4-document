import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'Account' })
export class Account {
  @PrimaryGeneratedColumn()
  UserId: number;

  @Column({ type: 'text' })
  UserName: string;

  @Column({ type: 'text', unique: true })
  Email: string;

  @Column({ type: 'text' })
  PasswordHash: string;

  @Column({ type: 'text', nullable: true })
  UserImg?: string | null;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  CreatedAt: Date;

  @Column({ type: 'datetime', nullable: true })
  LastLogin?: Date | null;

  @Column({ type: 'integer', nullable: true })
  UsedCapacity?: number | null;

  @Column({ type: 'integer', nullable: true })
  Capacity?: number | null;
}
