
const ROUTES_METADATA = Symbol('ROUTES_METADATA');

export interface RouteDefinition {
  path: string;
  method: 'get' | 'post' | 'put' | 'patch' | 'delete';
  handlerName: string | symbol;
}

function createMethodDecorator(method: RouteDefinition['method']) {
  return (path: string = ''): MethodDecorator => {
    return (target, propertyKey) => {
      const routes: RouteDefinition[] =
        Reflect.getMetadata(ROUTES_METADATA, target.constructor) || [];

      routes.push({ path, method, handlerName: propertyKey });

      Reflect.defineMetadata(ROUTES_METADATA, routes, target.constructor);
    };
  };
}

export const Get = createMethodDecorator('get');
export const Post = createMethodDecorator('post');
export const Put = createMethodDecorator('put');
export const Patch = createMethodDecorator('patch');
export const Delete = createMethodDecorator('delete');

export function getRoutes(target: any): RouteDefinition[] {
  return Reflect.getMetadata(ROUTES_METADATA, target) || [];
}
