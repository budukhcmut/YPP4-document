// src/app.ts
import { DIContainer, Lifecycle } from "./container";
import { UserService } from "./services/user.service";
const container = new DIContainer();

// Đăng ký 3 lifecycle khác nhau
container.register("UserServiceSingleton", UserService, Lifecycle.Singleton);
container.register("UserServiceTransient", UserService, Lifecycle.Transient);
container.register("UserServiceScoped", UserService, Lifecycle.Scoped);

// -----------------------
// Singleton test
const s1 = container.resolve<UserService>("UserServiceSingleton");
const s2 = container.resolve<UserService>("UserServiceSingleton");
console.log("Singleton:", s1.getInfo(), s1 === s2); // true

// Transient test
const t1 = container.resolve<UserService>("UserServiceTransient");
const t2 = container.resolve<UserService>("UserServiceTransient");
console.log("Transient:", t1.getInfo(), t1 === t2); // false

// Scoped test
const scopeA1 = container.resolve<UserService>("UserServiceScoped", "scopeA");
const scopeA2 = container.resolve<UserService>("UserServiceScoped", "scopeA");
console.log("Scoped A:", scopeA1.getInfo(), scopeA1 === scopeA2); // true

const scopeB1 = container.resolve<UserService>("UserServiceScoped", "scopeB");
console.log("Scoped B:", scopeB1.getInfo(), scopeB1 === scopeA1); // false

// Singleton: chỉ tạo 1 instance → s1 === s2

// Transient: mỗi lần resolve tạo instance mới → t1 !== t2

// Request-scoped: mỗi scope (request) có 1 instance riêng

// Trong cùng scope → r1 === r2

// Scope khác → r3 !== r1

// Kết thúc scope A
container.clearScope("scopeA");