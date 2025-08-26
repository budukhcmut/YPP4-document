// user.controller.spec.ts
import 'reflect-metadata';
import { getControllerPrefix, getRoutes } from './index';
import { UserController } from './controller'

describe('UserController Decorators', () => {
  it('should have controller prefix metadata', () => {
    const prefix = getControllerPrefix(UserController);
    expect(prefix).toBe('/users');
  });

  it('should have route metadata for methods', () => {
    const routes = getRoutes(UserController);

    expect(routes).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          path: '',
          method: 'get',
          handlerName: 'findAll',
        }),
        expect.objectContaining({
          path: ':id',
          method: 'get',
          handlerName: 'findOne',
        }),
        expect.objectContaining({
          path: '',
          method: 'post',
          handlerName: 'create',
        }),
      ]),
    );
  });
});

describe('UserController Logic', () => {
  let controller: UserController;

  beforeEach(() => {
    controller = new UserController();
  });

  it('should return all users', () => {
    const result = controller.findAll();
    expect(result).toEqual([{ id: 1, name: 'Khiem' }]);
  });

  it('should return a user by id', () => {
    const result = controller.findOne(1);
    expect(result).toEqual({ id: 1, name: 'Khiem' });
  });

  it('should create a new user', () => {
    const newUser = { id: 2, name: 'Duc' };
    const result = controller.create(newUser);
    expect(result).toEqual(newUser);
    expect(controller.findAll()).toHaveLength(2);
  });
});
