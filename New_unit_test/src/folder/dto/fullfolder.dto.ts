export class MyFolderDto {
  FolderId: number;
  ParentId?: number | null;
  OwnerId: number;
  UserName: string;
  FolderName: string;
  FolderPath?: string | null;
  FolderStatus?: string | null;
  ColorId?: number | null;
  CreatedAt: Date;
  UpdatedAt?: Date | null;
}
