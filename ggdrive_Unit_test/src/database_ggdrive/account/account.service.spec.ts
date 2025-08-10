import { Test, TestingModule } from '@nestjs/testing';
import { AccountService } from './account.service';
import { Account } from '../entities/account.entity';

describe('AccountService', () => {
  let service: AccountService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AccountService],
    }).compile();

    service = module.get<AccountService>(AccountService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll()', () => {
    it('should return an empty array when no accounts exist', () => {
      const accounts = service.findAll();
      expect(accounts).toEqual([]);
    });

    it('should return all created accounts', () => {
      const account1 = {
        UserId: 1,
        Username: 'Quan',
        Email: 'quanvo@example.com',
        PasswordHash: 'SecurePass123!',
        UserImg: 'https://example.com/avatar.jpg',
        UsedCapacity: 0,
        Capacity: 1000,
        CreatedAt: new Date(),
      };
      const account2 = {
        UserId: 2,
        Username: 'QuanDinh',
        Email: 'quandinh@example.com',
        PasswordHash: 'SecurePass123!',
        UserImg: 'https://example.com/avatar.jpg',
        UsedCapacity: 0,
        Capacity: 1000,
        CreatedAt: new Date(),
      };

      service.create(account1);
      service.create(account2);

      const accounts = service.findAll();
      expect(accounts).toEqual([account1, account2]);
    });
  });

  describe('findOne()', () => {
    it('should throw an error when account does not exist', () => {
      expect(() => service.findOne(999)).toThrow('Tài khoản không tồn tại');
    });

    it('should return the account when it exists', () => {
      const account = {
        UserId: 1,
        Username: 'Quan',
        Email: 'quanvo@example.com',
        PasswordHash: 'SecurePass123!',
        UserImg: 'https://example.com/avatar.jpg',
        UsedCapacity: 0,
        Capacity: 1000,
        CreatedAt: new Date(),
      };

      service.create(account);

      const result = service.findOne(1);
      expect(result).toEqual(account);
    });
  });

  describe('update()', () => {
    const baseAccount = {
      UserId: 1,
      Username: 'Quan',
      Email: 'quanvo@example.com',
      PasswordHash: 'SecurePass123!',
      UserImg: 'https://example.com/avatar.jpg',
      UsedCapacity: 0,
      Capacity: 1000,
      CreatedAt: new Date(),
    };

    it('should update the account when it exists', () => {
      const account = { ...baseAccount };
      service.create(account);

      const updatedAccount = { ...account, Username: 'Updated' };
      const result = service.update(1, updatedAccount);

      expect(result).toEqual(updatedAccount);
    });

    it('should throw an error when account does not exist', () => {
      const updatedAccount = { ...baseAccount, Username: 'Updated' };

      expect(() => service.update(999, updatedAccount)).toThrow(
        'Tài khoản không tồn tại',
      );
    });

    it('should throw an error for invalid email format', () => {
      const account = { ...baseAccount };
      service.create(account);

      const updatedAccount = { ...account, Email: 'invalid-email' };

      expect(() => service.update(1, updatedAccount)).toThrow(
        'Định dạng email không hợp lệ',
      );
    });

    it('should throw an error for empty password', () => {
      const account = { ...baseAccount };
      service.create(account);

      const updatedAccount = { ...account, PasswordHash: '' };

      expect(() => service.update(1, updatedAccount)).toThrow(
        'Mật khẩu không được để trống',
      );
    });

    it('should throw an error for weak password', () => {
      const account = { ...baseAccount };
      service.create(account);

      const updatedAccount = { ...account, PasswordHash: '123456' };

      expect(() => service.update(1, updatedAccount)).toThrow(
        'Mật khẩu phải dài ít nhất 8 ký tự, chứa ít nhất một chữ hoa và một số',
      );
    });

    it('should throw an error for missing username', () => {
      const account = { ...baseAccount };
      service.create(account);

      const updatedAccount = { ...account, Username: '' };

      expect(() => service.update(1, updatedAccount)).toThrow(
        'Tên người dùng là bắt buộc',
      );
    });
  });

  describe('remove()', () => {
    it('should remove the account when it exists', () => {
      const account = {
        UserId: 1,
        Username: 'Quan',
        Email: 'quanvo@example.com',
        PasswordHash: 'SecurePass123!',
        UserImg: 'https://example.com/avatar.jpg',
        UsedCapacity: 0,
        Capacity: 1000,
        CreatedAt: new Date(),
      };
      service.create(account);

      service.remove(1);
      expect(() => service.findOne(1)).toThrow('Tài khoản không tồn tại');
    });

    it('should throw an error when account does not exist', () => {
      expect(() => service.remove(999)).toThrow('Tài khoản không tồn tại');
    });
  });
});