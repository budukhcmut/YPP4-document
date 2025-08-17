// src/services/user.service.ts
export class UserService {
  private createdAt: number;

  constructor() {
    this.createdAt = Date.now();
  }

  getInfo() {
    return `UserService instance created at ${this.createdAt}`;
  }
}