import { CreateAccountDto } from './dto/create-account.dto';
import { Account } from './entities/account.entity';

export class AccountRepository {
  private mockData: Account[] = [];

  create(account: CreateAccountDto) {
    const sql = `INSERT INTO Account (UserName, Email, PasswordHash, UserImg, UsedCapacity, Capacity) VALUES ('${account.userName}', '${account.email}', '${account.passwordHash}', '${account.userImg || null}', ${account.usedCapacity || null}, ${account.capacity || null})`;
    console.log('Executing SQL:', sql);

    const newAccount = new Account(
      this.mockData.length + 1,
      account.userName,
      account.email,
      account.passwordHash,
      new Date(),
      account.userImg,
      null,
      account.usedCapacity,
      account.capacity
    );
    this.mockData.push(newAccount);

    return newAccount;
  }

  findAll() {
    return this.mockData;
  }
}