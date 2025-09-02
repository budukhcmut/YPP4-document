import { Controller } from "src/decorator/controller/controller.decorator";
import { UserService } from "./user.service";
import { Get } from "src/decorator/route/router.decorator";

// controllers/user.controller.ts
@Controller('/users')
export class UserController {
  constructor(private userService: UserService) {} // auto injected

  @Get('/')
  list() { return this.userService.findAll(); }

  @Get('/:id')
  get(req: Request) {
    return this.userService.findById(Number(req.params.id));
  }
}
