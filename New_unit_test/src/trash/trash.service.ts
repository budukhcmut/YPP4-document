import { Injectable } from '@nestjs/common';
import { TrashRepository } from './trash.repository';
import { FileTrashDto } from './dto/filetrash.dto';
import { FolderTrashDto } from './dto/foldertrash.dto';


@Injectable()
export class TrashService {

      constructor(private readonly trashRepository: TrashRepository) {}
    
      async findTrashFiles(userId: number): Promise<FileTrashDto[]> {
        return this.trashRepository.findTrashFiles(userId);
      }
    
      async findTrashFolders(userId: number): Promise<FolderTrashDto[]> {
        return this.trashRepository.findTrashFolders(userId);
      }
    
}
