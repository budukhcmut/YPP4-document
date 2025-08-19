import { Injectable } from '@nestjs/common';

@Injectable()
export class CacheService {
  private cache = new Map<string, { data: any; expires: number }>();

  get<T>(key: string): T | null {
    const cached = this.cache.get(key);
    if (!cached) return null;

    if (cached.expires > Date.now()) {
      return cached.data as T;
    }

    this.cache.delete(key);
    return null;
  }

  set<T>(key: string, value: T, ttlSeconds = 300): void {
    this.cache.set(key, {
      data: value,
      expires: Date.now() + ttlSeconds * 1000,
    });
  }
}