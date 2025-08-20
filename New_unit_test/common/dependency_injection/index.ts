enum Lifetime {
  Transient,
  Singleton,
  Scoped,
}

interface IScope extends Disposable {
  resolve<T>(): T;
}

class SimpleContainer {
  private readonly registrations: Map<
    Function,
    { implType: Function; lifetime: Lifetime }
  > = new Map();
  private readonly singletons: Map<Function, any> = new Map();
  private readonly ctorCache: Map<Function, Function> = new Map();

  public register<TInterface, TImplementation extends TInterface>(
    lifetime: Lifetime = Lifetime.Transient,
  ): void {
    this.registrations.set(TInterface, { implType: TImplementation, lifetime });
  }

  public registerImplementation<TImplementation>(
    lifetime: Lifetime = Lifetime.Transient,
  ): void {
    this.registrations.set(TImplementation, {
      implType: TImplementation,
      lifetime,
    });
  }

  public resolve<T>(): T {
    return this.resolveInternal(T, null) as T;
  }

  public createScope(): IScope {
    return new Scope(this);
  }

  private resolveInternal(type: Function, scope: Scope | null): any {
    const entry = this.registrations.get(type);
    if (!entry) {
      throw new Error(`Type ${type.name} is not registered.`);
    }

    switch (entry.lifetime) {
      case Lifetime.Singleton:
        const existing = this.singletons.get(type);
        if (existing) {
          return existing;
        }
        const instance = this.createInstance(entry.implType, scope);
        this.singletons.set(type, instance);
        return instance;

      case Lifetime.Scoped:
        if (!scope) {
          throw new Error('Scoped service resolution requires an active scope');
        }
        return scope.getOrCreateScopedInstance(type, () =>
          this.createInstance(entry.implType, scope),
        );

      case Lifetime.Transient:
        return this.createInstance(entry.implType, scope);

      default:
        throw new Error('Unsupported lifetime');
    }
  }

  private createInstance(implType: Function, scope: Scope | null): any {
    let ctor = this.ctorCache.get(implType);
    if (!ctor) {
      // Using Function.prototype to simulate constructor retrieval
      ctor = implType;
      this.ctorCache.set(implType, ctor);
    }

    // In TypeScript, we can't directly access constructor parameters like in C#
    // We'll assume the constructor parameters are resolved through reflection-like mechanism
    // For simplicity, we'll create an instance using the constructor
    const instance = new (ctor as any)();
    return instance;
  }
}

class Scope implements IScope {
  private readonly container: SimpleContainer;
  private readonly scopedInstances: Map<Function, any> = new Map();
  private disposed: boolean = false;

  constructor(container: SimpleContainer) {
    this.container = container;
  }
  [Symbol.dispose](): void {
    this.disposed = true;
    this.scopedInstances.clear();
  }

  public resolve<T>(): T {
    return this.container.resolveInternal(T, this) as T;
  }

  public getOrCreateScopedInstance(type: Function, factory: () => any): any {
    if (this.disposed) {
      throw new Error('Scope is disposed');
    }

    let instance = this.scopedInstances.get(type);
    if (!instance) {
      instance = factory();
      this.scopedInstances.set(type, instance);
    }

    return instance;
  }
}