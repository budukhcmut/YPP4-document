import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite', // Loại cơ sở dữ liệu
      database: 'db.sqlite', // Tên tệp cơ sở dữ liệu (sẽ tự tạo nếu chưa tồn tại)
      entities: [__dirname + '/**/*.entity{.ts,.js}'], // Đường dẫn đến các entity
      synchronize: true, // Tự động tạo schema (chỉ dùng trong phát triển)
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
