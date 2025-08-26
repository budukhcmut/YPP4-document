// user.controller.ts
import { Controller, Get, Post } from './index';

@Controller('/users')
export class UserController {
  private users = [{ id: 1, name: 'Khiem' }];

  @Get()
  findAll() {
    return this.users;
  }

  @Get(':id')
  findOne(id: number) {
    return this.users.find((u) => u.id === id);
  }

  @Post()
  create(user: { id: number; name: string }) {
    this.users.push(user);
    return user;
  }
}
