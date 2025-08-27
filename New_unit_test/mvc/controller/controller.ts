// user.controller.ts
import { Get, Post } from "../decorator/router.decorator";
import { Controller } from "../decorator/controller.decorator";
import { Body, Param } from "../decorator/parameter.decorator";

@Controller('/users')
export class UserController {
  private users = [{ id: 1, name: 'Khiem' }];

  @Get()
  findAll() {
    return this.users;
  }

  @Get(':id')
  findOne(@Param('id') id: number) {
    return this.users.find((u) => u.id === Number(id));
  }

  @Post()
  create(@Body() user: { id: number; name: string }) {
    this.users.push(user);
    return user;
  }
}
