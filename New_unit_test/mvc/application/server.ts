import http from 'http';
import { Router } from '../core/router';

export class Server {
  constructor(private router: Router) {}

  listen(port: number) {
    const server = http.createServer((req, res) => {
      this.router.handler(req, res);
    });

    server.listen(port, () => {
      console.log(`🚀 Server running at http://localhost:${port}`);
    });
  }
}
