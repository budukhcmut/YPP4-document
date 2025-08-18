export class UserFileFullDto {
  FileId: number;
  FolderId?: number | null;
  OwnerId: number;
  Size?: number | null;
  UserFileName: string;
  UserFilePath?: string | null;
  UserFileThumbNailImg?: string | null;
  FileTypeId?: number | null;
  ModifiedDate?: string | null; // keep string for raw DB output; you can transform to Date if needed
  UserFileStatus?: string | null;
  CreatedAt: string;
}
