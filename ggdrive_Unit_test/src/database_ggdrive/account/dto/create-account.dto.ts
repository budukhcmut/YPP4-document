export class CreateAccountDto {
  userName: string;
  email: string;
  passwordHash: string;
  userImg?: string;
  usedCapacity?: number;
  capacity?: number;
}