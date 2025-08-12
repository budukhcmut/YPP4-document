import { Test, TestingModule } from '@nestjs/testing';
import { AccountService } from './account.service';
import { AccountRepository } from './account.repository';
import { CreateAccountDto } from './dto/create-account.dto';
import { Account } from './entities/account.entity';

describe('AccountService - create()', () => {
  let accountService: AccountService;
  let accountRepository: AccountRepository;

  beforeEach(async () => {
    const mockAccountRepository = {
      create: jest.fn((data) => new Account(
        1,
        data.userName,
        data.email,
        data.passwordHash,
        new Date(),
        data.userImg,
        null,
        data.usedCapacity,
        data.capacity
      )),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AccountService,
        { provide: AccountRepository, useValue: mockAccountRepository },
      ],
    }).compile();

    accountService = module.get<AccountService>(AccountService);
    accountRepository = module.get<AccountRepository>(AccountRepository);
  });

  it('should create an account successfully', () => {
    const dto: CreateAccountDto = {
      userName: 'john_doe',
      email: 'john.doe@example.com',
      passwordHash: 'hashed_password_123',
      userImg: 'profile1.jpg',
      usedCapacity: 5000000,
      capacity: 1000000000,
    };

    const result = accountService.create(dto);

    expect(accountRepository.create).toHaveBeenCalledWith({
      userName: dto.userName,
      email: dto.email,
      passwordHash: dto.passwordHash,
      userImg: dto.userImg,
      usedCapacity: dto.usedCapacity,
      capacity: dto.capacity,
    });

    expect(result).toHaveProperty('userId', 1);
    expect(result.userName).toBe(dto.userName);
    expect(result.email).toBe(dto.email);
    expect(result.passwordHash).toBe(dto.passwordHash);
  });
});