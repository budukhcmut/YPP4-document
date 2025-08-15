import { Test, TestingModule } from '@nestjs/testing';
import { ShareController } from './share.controller';
import { ShareService } from './share.service';

describe('ShareController', () => {
  let controller: ShareController;
  let service: ShareService;

  const mockShareService = {
    getSharedFiles: jest.fn(),
    getSharedFolders: jest.fn(),
    getSharedFilesWithPermission: jest.fn(),
    getSharedFoldersWithPermission: jest.fn(),
  };

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ShareController],
      providers: [
        {
          provide: ShareService,
          useValue: mockShareService,
        },
      ],
    }).compile();

    controller = module.get<ShareController>(ShareController);
    service = module.get<ShareService>(ShareService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getSharedFiles', () => {
    it('should return shared files for a specific user', async () => {
      const mockResult = [{ id: 1, name: 'file1' }];
      service.getSharedFiles = jest.fn().mockResolvedValue(mockResult);

      const result = await controller.getSharedFiles(1);

      expect(result).toEqual(mockResult);
      expect(service.getSharedFiles).toHaveBeenCalledWith(1);
    });

    it('should return an empty array for a non-existent user', async () => {
      service.getSharedFiles = jest.fn().mockResolvedValue([]);

      const result = await controller.getSharedFiles(-1);

      expect(result).toEqual([]);
      expect(service.getSharedFiles).toHaveBeenCalledWith(-1);
    });
  });

  describe('getSharedFolders', () => {
    it('should return shared folders for a specific user', async () => {
      const mockResult = [{ id: 1, name: 'folder1' }];
      service.getSharedFolders = jest.fn().mockResolvedValue(mockResult);

      const result = await controller.getSharedFolders(1);

      expect(result).toEqual(mockResult);
      expect(service.getSharedFolders).toHaveBeenCalledWith(1);
    });

    it('should return an empty array for a non-existent user', async () => {
      service.getSharedFolders = jest.fn().mockResolvedValue([]);

      const result = await controller.getSharedFolders(-1);

      expect(result).toEqual([]);
      expect(service.getSharedFolders).toHaveBeenCalledWith(-1);
    });
  });

  describe('getSharedFilesWithPermission', () => {
    it('should return shared files with permission for a specific user', async () => {
      const mockResult = [{ id: 1, name: 'file-perm1' }];
      service.getSharedFilesWithPermission = jest
        .fn()
        .mockResolvedValue(mockResult);

      const result = await controller.getSharedFilesWithPermission(1);

      expect(result).toEqual(mockResult);
      expect(service.getSharedFilesWithPermission).toHaveBeenCalledWith(1);
    });

    it('should return an empty array for a non-existent user', async () => {
      service.getSharedFilesWithPermission = jest.fn().mockResolvedValue([]);

      const result = await controller.getSharedFilesWithPermission(-1);

      expect(result).toEqual([]);
      expect(service.getSharedFilesWithPermission).toHaveBeenCalledWith(-1);
    });
  });

  describe('getSharedFoldersWithPermission', () => {
    it('should return shared folders with permission for a specific user', async () => {
      const mockResult = [{ id: 1, name: 'folder-perm1' }];
      service.getSharedFoldersWithPermission = jest
        .fn()
        .mockResolvedValue(mockResult);

      const result = await controller.getSharedFoldersWithPermission(1);

      expect(result).toEqual(mockResult);
      expect(service.getSharedFoldersWithPermission).toHaveBeenCalledWith(1);
    });

    it('should return an empty array for a non-existent user', async () => {
      service.getSharedFoldersWithPermission = jest.fn().mockResolvedValue([]);

      const result = await controller.getSharedFoldersWithPermission(-1);

      expect(result).toEqual([]);
      expect(service.getSharedFoldersWithPermission).toHaveBeenCalledWith(-1);
    });
  });
});
