import { Controller, Get, Post, Body, Param, Delete, Put } from '@nestjs/common';
import { TrashService } from './trash.service';
import { FileTrashDto } from './dto/filetrash.dto';
import { FolderTrashDto } from './dto/foldertrash.dto';


@Controller('trash')
export class TrashController {
  constructor(private readonly trashService: TrashService) {}

  async findTrashFiles(
 accountId : number ,
  ):Promise<FileTrashDto[]>{
    return await this.trashService.findTrashFiles(accountId);
   
  }
async findTrashFolders(
    accountId: number,      
  ): Promise<FolderTrashDto[]> {
    return await this.trashService.findTrashFolders(accountId);
  }}

 