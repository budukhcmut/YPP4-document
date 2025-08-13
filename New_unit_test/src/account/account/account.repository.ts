import { Injectable } from '@nestjs/common';
import { BasicInfoDto } from 'src/account/account/dto/account.dto';
import { DataSource } from 'typeorm';

@Injectable()
export class AccountRepository {
  constructor(private dataSource: DataSource) {}

  async findBasicInfoByUserId(userId: number): Promise<BasicInfoDto[]> {
    const sql = `
      SELECT a.UserName AS UserName, a.Email AS Email
      FROM Account a
      WHERE a.UserId = ?
    `;
    return this.dataSource.query(sql, [userId]);
  }
}
