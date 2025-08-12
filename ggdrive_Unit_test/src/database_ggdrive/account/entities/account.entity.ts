export class Account {
  constructor(
    public userId: number,
    public userName: string,
    public email: string,
    public passwordHash: string,
    public createdAt: Date,
    public userImg?: string,
    public lastLogin?: Date | null,
    public usedCapacity?: number | null,
    public capacity?: number | null
  ) {}
}