import 'reflect-metadata';

export enum Scope {
  SINGLETON = 'SINGLETON',
}

export type Newable<T = unknown> = new (...args: unknown[]) => T;
type Token<T = any> = Newable<T> | string | symbol;


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

   private static instances = new Map<Token, any>();

  /**
   * Đăng ký một instance cho token (class hoặc string/symbol).
   * Ứng dụng của bạn có thể gọi: Container.set(MyService, new MyService());
   */
  static set<T = any>(token: Token<T>, instance: T): void {
    this.instances.set(token, instance);
  }

  /**
   * Lấy instance theo token.
   * - Nếu đã có instance => trả ngay.
   * - Nếu chưa có và token là constructor => tự resolve constructor params và khởi tạo, sau đó cache.
   * - Nếu token là string/symbol và chưa được set => trả undefined.
   */
  static get<T = any>(token: Token<T>): T | undefined {
    if (this.instances.has(token)) {
      return this.instances.get(token);
    }

    // Nếu token không phải là constructor (ví dụ string) thì không thể tự tạo
    if (typeof token !== "function") {
      return undefined;
    }

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


