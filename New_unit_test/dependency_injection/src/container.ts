// Nó nghĩa là: Constructor<T> là một class được khởi tạo bằng new với bất kỳ tham số nào và trả về instance kiểu T.

// Dùng để container biết “class nào cần tạo instance”
type Constructor<T> = new (...args: any[]) => T;

enum Lifecycle {
  Singleton, // Chỉ tạo 1 instance duy nhất
  Transient, // Mỗi lần resolve sẽ tạo instance mới
  Scoped, // Mỗi scope (request) có 1 instance riêng
}
class DIContainer {
  private singletons = new Map<string, any>(); // lưu các instance Singleton. Key là token string.
  private registrations = new Map<
    string,
    { class: Constructor<any>; lifecycle: Lifecycle }
  >(); // lưucác service đã đăng ký: token -> {class, lifecycle}
  private scopedInstances = new Map<string, any>(); // lưu instance của các service Scoped. Key là scopeId_token.

  //   Hàm đăng ký service vào container.
  // token → tên định danh service (string).
  // cls → class sẽ được container tạo instance.
  // Lưu vào registrations để container biết cách tạo instance sau này.
  register<T>(token: string, cls: Constructor<T>, lifecycle: Lifecycle) {
    this.registrations.set(token, { class: cls, lifecycle });
  }

  // lấy instance của service từ container.
  resolve<T>(token: string, scopeId?: string): T {
    const registration = this.registrations.get(token);
    if (!registration) throw new Error(`Service ${token} not registered`);

    const { class: Cls, lifecycle } = registration;

    switch (lifecycle) {
      // Lưu vào singletons.
      // Trả về instance đã lưu (các lần resolve sau sẽ return cùng instance).
      case Lifecycle.Singleton:
        if (!this.singletons.has(token)) {
          this.singletons.set(token, new Cls());
        }
        return this.singletons.get(token);

      // Mỗi lần resolve → tạo instance mới bằng new Cls().
      // Không lưu lại, lần sau resolve → instance khác.
      case Lifecycle.Transient:
        return new Cls();

      // Phải truyền scopeId (ví dụ request ID) để biết instance này thuộc scope nào.
      // Key = scopeId_token để phân biệt các scope.
      // Nếu chưa có instance cho scope này → tạo mới và lưu vào scopedInstances.
      // Trả về instance tương ứng của scope hiện tại.
      case Lifecycle.Scoped:
        if (!scopeId)
          throw new Error(`ScopeId is required for Scoped services`);
        const scopedKey = `${scopeId}_${token}`;
        if (!this.scopedInstances.has(scopedKey)) {
          this.scopedInstances.set(scopedKey, new Cls());
        }
        return this.scopedInstances.get(scopedKey);

      default:
        throw new Error(`Unknown lifecycle for ${token}`);
    }
  }

  // Xoá scope khi request xong
  clearScope(scopeId: string) {
    [...this.scopedInstances.keys()]
      .filter((key) => key.startsWith(scopeId))
      .forEach((key) => this.scopedInstances.delete(key));
  }
}

export { DIContainer, Lifecycle };