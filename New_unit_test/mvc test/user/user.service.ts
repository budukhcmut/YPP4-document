// services/user.service.ts
export class UserService {
  private users = [{ id: 1, name: 'Alice' }];

  findAll() { return this.users; }
  findById(id: number) { return this.users.find(u => u.id === id); }
  create(name: string) {
    const id = this.users.length + 1;
    const u = { id, name };
    this.users.push(u);
    return u;
  }
}
