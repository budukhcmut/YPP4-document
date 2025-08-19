export class FileTrashDto {
  trashId: number;
  objectTypeName: string ;
  fileId: number;
  fileName: string;
  removedDatetime: string;
  isPermanent: boolean;
}