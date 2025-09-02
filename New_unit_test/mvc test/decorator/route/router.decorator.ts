// decorators.ts//ok
import 'reflect-metadata';

export type HttpMethod = 'get' | 'post' | 'put' | 'patch' | 'delete';

export interface RouteDefinition {
  path: string;
  method: HttpMethod;
  handlerName: string; // use string for simplicity
  middlewares?: Function[];
}

const ROUTES_METADATA = Symbol('ROUTES_METADATA');
const CONTROLLER_PATH = Symbol('CONTROLLER_PATH');

/**
 * Controller decorator
 */
export function Controller(basePath: string = ''): ClassDecorator {
  return (target) => {
    Reflect.defineMetadata(CONTROLLER_PATH, basePath, target);
    if (!Reflect.hasMetadata(ROUTES_METADATA, target)) {
      Reflect.defineMetadata(ROUTES_METADATA, [] as RouteDefinition[], target);
    }
  };
}

/**
 * Creates method decorators like @Get, @Post...
 */
function createMethodDecorator(method: HttpMethod) {
  return (path = '', ...middlewares: Function[]): MethodDecorator => {
    return (target, propertyKey) => {
      const constructor = target.constructor as any;
      const routes: RouteDefinition[] =
        Reflect.getMetadata(ROUTES_METADATA, constructor) ?? [];

      routes.push({
        path,
        method,
        handlerName: propertyKey.toString(),
        middlewares,
      });

      Reflect.defineMetadata(ROUTES_METADATA, routes, constructor);
    };
  };
}

export const Get = createMethodDecorator('get');
export const Post = createMethodDecorator('post');
export const Put = createMethodDecorator('put');
export const Patch = createMethodDecorator('patch');
export const Delete = createMethodDecorator('delete');

/**
 * Helpers to read metadata (used by router/application)
 */
export function getControllerPath(target: any): string {
  return Reflect.getMetadata(CONTROLLER_PATH, target) ?? '';
}

export function getRoutes(target: any): RouteDefinition[] {
  return Reflect.getMetadata(ROUTES_METADATA, target) ?? [];
}
