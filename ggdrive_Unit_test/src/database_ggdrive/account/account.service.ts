import { Injectable } from '@nestjs/common';
import { Account } from '../entities/account.entity';

@Injectable()
export class AccountService {
  private accounts: Account[] = [];

  create(account: Account): Account {
    const email = account.Email.trim().toLowerCase();
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      throw new Error('Định dạng email không hợp lệ');
    }

    if (!account.PasswordHash || account.PasswordHash.trim() === '') {
      throw new Error('Mật khẩu không được để trống');
    }

    if (
      account.PasswordHash.length < 8 ||
      !/[A-Z]/.test(account.PasswordHash) ||
      !/\d/.test(account.PasswordHash)
    ) {
      throw new Error(
        'Mật khẩu phải dài ít nhất 8 ký tự, chứa ít nhất một chữ hoa và một số',
      );
    }

    if (!account.Username) {
      throw new Error('Tên người dùng là bắt buộc');
    }

    const existingAccount = this.accounts.find(
      (acc) => acc.Email.toLowerCase() === email,
    );
    if (existingAccount) {
      throw new Error('Tài khoản với email này đã tồn tại');
    }

    account.UserId = this.accounts.length + 1;
    this.accounts.push(account);
    return account;
  }

  findAll(): Account[] {
    return this.accounts;
  }

  findOne(id: number): Account {
    const account = this.accounts.find((acc) => acc.UserId === id);

    if (!account) {
      throw new Error('Tài khoản không tồn tại');
    }

    return account;
  }

  update(id: number, account: Account): Account {
    const index = this.accounts.findIndex((acc) => acc.UserId === id);

    if (index === -1) {
      throw new Error('Tài khoản không tồn tại');
    }

    const email = account.Email.trim().toLowerCase();

    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      throw new Error('Định dạng email không hợp lệ');
    }

    if (!account.PasswordHash || account.PasswordHash.trim() === '') {
      throw new Error('Mật khẩu không được để trống');
    }

    if (
      account.PasswordHash.length < 8 ||
      !/[A-Z]/.test(account.PasswordHash) ||
      !/\d/.test(account.PasswordHash)
    ) {
      throw new Error(
        'Mật khẩu phải dài ít nhất 8 ký tự, chứa ít nhất một chữ hoa và một số',
      );
    }

    if (!account.Username) {
      throw new Error('Tên người dùng là bắt buộc');
    }

    const existingAccount = this.accounts.find(
      (acc) => acc.Email.toLowerCase() === email && acc.UserId !== id,
    );
    if (existingAccount) {
      throw new Error('Tài khoản với email này đã tồn tại');
    }

    this.accounts[index] = account;
    return account;
  }

  remove(id: number): void {
    const index = this.accounts.findIndex((acc) => acc.UserId === id);

    if (index === -1) {
      throw new Error('Tài khoản không tồn tại');
    }

    this.accounts.splice(index, 1);
  }
}