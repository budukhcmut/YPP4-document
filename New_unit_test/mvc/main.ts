import express from 'express';
import bodyParser from 'body-parser';
import { Container, getControllerPrefix, getRoutes } from './index' ;
import { UserController } from './controller';

async function bootstrap() {
  const app = express();
  app.use(bodyParser.json());

  // Đăng ký tất cả controller ở đây (có thể tự động scan folder sau)
  const controllers = [UserController];

  controllers.forEach((ControllerClass) => {
    const prefix = getControllerPrefix(ControllerClass);
    const routes = getRoutes(ControllerClass);
    const controllerInstance = Container.resolve(ControllerClass);

    routes.forEach(({ path, method, handlerName }) => {
      const fullPath = prefix + (path ? `/${path}` : '');
      app[method](fullPath, async (req, res, next) => {
        try {
          // gọi hàm controller
          const result = await controllerInstance[handlerName](req, res, next);
          if (!res.headersSent) {
            res.json(result);
          }
        } catch (err) {
          next(err);
        }
      });
    });
  });

  app.listen(3000, () =>
    console.log('🚀 Server running on http://localhost:3000'),
  );
}

bootstrap();
