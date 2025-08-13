// src/account/account/account.controller.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import { AccountRepository } from './account.repository';
import { Account } from './entities/account.entity'; // <-- dùng đường dẫn tương đối

describe('AccountController raw SQL query', () => {
  let moduleRef: TestingModule;
  let controller: AccountController;
  let dataSource: DataSource;

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          entities: [Account],
          synchronize: true,
          dropSchema: true,
        }),
        TypeOrmModule.forFeature([Account]),
      ],
      controllers: [AccountController],
      providers: [AccountRepository, AccountService],
    }).compile();

    controller = moduleRef.get(AccountController);
    dataSource = moduleRef.get(DataSource);

    // Seed dữ liệu
    await dataSource.getRepository(Account).insert([
      {
        UserName: 'alice',
        Email: 'alice@example.com',
        PasswordHash: 'hash-a',
        UsedCapacity: 50,
        Capacity: 100,
      },
      {
        UserName: 'bob',
        Email: 'bob@example.com',
        PasswordHash: 'hash-b',
        UsedCapacity: 10,
        Capacity: 100,
      },
    ]);
  });

  afterAll(async () => {
    await moduleRef.close();
  });

  it('GET /account/:id/basic-info trả về đúng UserName và Email', async () => {
    const alice = await dataSource
      .getRepository(Account)
      .findOneOrFail({ where: { Email: 'alice@example.com' } });

    const rows = await controller.getBasicInfo(alice.UserId);

    expect(rows).toEqual([{ UserName: 'alice', Email: 'alice@example.com' }]);
  });
});
