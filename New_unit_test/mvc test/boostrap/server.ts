// server.ts
import 'reflect-metadata';
import { Application } from './application';

// import your controllers here (replace with your real controllers)
import { UserController } from './controllers/user.controller';

async function bootstrap() {
  const app = new Application();

  // register global middlewares if needed
  // app.registerMiddleware(app => { app.use(someMiddleware) });

  // register controllers (pass the controller classes)
  app.registerControllers([
    UserController,
    // add other controller classes here
  ]);

  await app.listen(process.env.PORT || 3000);
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap application', err);
  process.exit(1);
});
