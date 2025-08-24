import 'reflect-metadata';

export enum Scope {
  SINGLETON = 'SINGLETON',
}

export type Newable<T = unknown> = new (...args: unknown[]) => T;

export interface ProviderInfo<T = unknown> {
  instance?: T;
  scope: Scope;
}

export const container = new Map<Newable, ProviderInfo>();

export class Container {
  static register(provider: Newable, scope: Scope = Scope.SINGLETON): void {
    void (container.get(provider) ?? container.set(provider, { scope }));
  }

  static resolve<T>(provider: Newable<T>): T {
    const metadata = container.get(provider);
    if (!metadata) {
      throw new Error(`Class ${provider.name} is not registered`);
    }

    const { instance, scope } = metadata;

    if (scope === Scope.SINGLETON) {
      if (!instance) {
        const newInstance = Container.createInstance(provider);
        container.set(provider, { instance: newInstance, scope });
        return newInstance;
      }
      return instance as T;
    }

    throw new Error('Unsupported scope');
  }

  private static createInstance<T>(provider: Newable<T>): T {
    const metadata =
      (Reflect.getMetadata('design:paramtypes', provider) as
        | Newable[]
        | undefined) || [];

    const resolvedDeps = metadata.map((dep) => Container.resolve(dep));
    return new provider(...resolvedDeps);
  }
}

export function Injectable(option?: { scope?: Scope }) {
  return function (provider: Newable) {
    const scope = option?.scope || Scope.SINGLETON;
    Container.register(provider, scope);
  };
}

/**
 * ------------------------
 * Controller Decorators
 * ------------------------
 */

const CONTROLLER_METADATA = Symbol('CONTROLLER_METADATA');
const ROUTES_METADATA = Symbol('ROUTES_METADATA');

export interface RouteDefinition {
  path: string;
  method: 'get' | 'post' | 'put' | 'delete';
  handlerName: string | symbol;
}

export function Controller(prefix: string = ''): ClassDecorator {
  return (target: any) => {
    Reflect.defineMetadata(CONTROLLER_METADATA, prefix, target);
    Container.register(target); // Controller cũng được quản lý bởi Container
  };
}

function createMethodDecorator(method: 'get' | 'post' | 'put' | 'delete') {
  return (path: string = ''): MethodDecorator => {
    return (target, propertyKey) => {
      const routes: RouteDefinition[] =
        Reflect.getMetadata(ROUTES_METADATA, target.constructor) || [];

      routes.push({
        path,
        method,
        handlerName: propertyKey,
      });

      Reflect.defineMetadata(ROUTES_METADATA, routes, target.constructor);
    };
  };
}

export const Get = createMethodDecorator('get');
export const Post = createMethodDecorator('post');
export const Put = createMethodDecorator('put');
export const Delete = createMethodDecorator('delete');

// helper để lấy metadata
export function getControllerPrefix(target: any): string {
  return Reflect.getMetadata(CONTROLLER_METADATA, target);
}

export function getRoutes(target: any): RouteDefinition[] {
  return Reflect.getMetadata(ROUTES_METADATA, target) || [];
}
