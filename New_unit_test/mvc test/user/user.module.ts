// src/application/app.module.ts
import { Module } from "../decorator/module.decorator";
import { UserController } from "./user.controller";
import { UserService } from "./user.service";

@Module({
  controllers: [UserController],
  providers: [UserService],
})
export class UserModule {}
