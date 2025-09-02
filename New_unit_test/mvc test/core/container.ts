//ok

import "reflect-metadata";

export enum Scope {
  SINGLETON = "SINGLETON",
}

export type Newable<T = unknown> = new (...args: unknown[]) => T;
export type Token<T = any> = Newable<T> | string | symbol;

export interface ProviderInfo<T = unknown> {
  instance?: T;
  scope: Scope;
}

const container = new Map<Newable, ProviderInfo>();

export class Container {
  private static instances = new Map<Token, any>();

  static register(provider: Newable, scope: Scope = Scope.SINGLETON): void {
    if (!container.has(provider)) {
      container.set(provider, { scope });
    }
  }

  static resolve<T>(provider: Newable<T>): T {
    const metadata = container.get(provider);
    if (!metadata) {
      // nếu chưa register thì tự động register
      Container.register(provider);
      return Container.resolve(provider);
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

    throw new Error("Unsupported scope");
  }

  /**
   * Đăng ký một instance cho token (class hoặc string/symbol).
   * Ứng dụng có thể gọi: Container.set(MyService, new MyService());
   */
  static set<T = any>(token: Token<T>, instance: T): void {
    this.instances.set(token, instance);
  }

  /**
   * Lấy instance theo token.
   * - Nếu đã có instance => trả ngay.
   * - Nếu chưa có và token là constructor => resolve qua DI.
   * - Nếu token là string/symbol và chưa được set => trả undefined.
   */
  static get<T = any>(token: Token<T>): T | undefined {
    if (this.instances.has(token)) {
      return this.instances.get(token);
    }

    if (typeof token === "function") {
      const resolved = Container.resolve(token);
      this.instances.set(token, resolved);
      return resolved;
    }

    return undefined; // string/symbol chưa set
  }

  private static createInstance<T>(provider: Newable<T>): T {
    const metadata =
      (Reflect.getMetadata("design:paramtypes", provider) as Newable[] | undefined) ||
      [];

    const resolvedDeps = metadata.map((dep) => Container.resolve(dep));
    return new provider(...resolvedDeps);
  }
}
