import { Injectable } from '@nestjs/common';
import { Account } from './entities/account.entity';
import { AccountRepository } from './account.repository';
import { CreateAccountDto } from './dto/create-account.dto';

@Injectable()
export class AccountService {
  private _mockData: Account[] = [];
  private _nextId = 1;

  get mockData(): Account[] {
    return this._mockData;
  }

  set mockData(data: Account[]) {
    this._mockData = data;
  }

  get nextId(): number {
    return this._nextId;
  }

  set nextId(id: number) {
    this._nextId = id;
  }

  constructor(private readonly accountRepository: AccountRepository) {}

  create(createAccountDto: CreateAccountDto) {
    const account = this.accountRepository.create({
      userName: createAccountDto.userName,
      email: createAccountDto.email,
      passwordHash: createAccountDto.passwordHash,
      userImg: createAccountDto.userImg,
      usedCapacity: createAccountDto.usedCapacity,
      capacity: createAccountDto.capacity,
    });
    this._mockData.push(account);
    this._nextId = Math.max(...this._mockData.map((a) => a.userId)) + 1;
    return account;
  }

  findAll(): Account[] {
    const sql = `SELECT * FROM Account`;
    console.log('🟢 SQL EXECUTED:', sql);
    return this._mockData;
  }

  getAccountById(userId: number): Account | null {
    const sql = `SELECT * FROM Account WHERE UserId = ${userId}`;
    console.log('🟢 SQL EXECUTED:', sql);
    return this._mockData.find((a) => a.userId === userId) ?? null;
  }

  delete(userId: number): boolean {
    const sql = `DELETE FROM Account WHERE UserId = ${userId}`;
    console.log('🟢 SQL EXECUTED:', sql);
    const lengthBefore = this._mockData.length;
    this._mockData = this._mockData.filter((a) => a.userId !== userId);
    return this._mockData.length < lengthBefore;
  }
}