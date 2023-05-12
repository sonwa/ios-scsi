//
//  EXManager.h
//  EXFileSystem
//
//  Created by macliu on 2023/5/12.
//

#import <Foundation/Foundation.h>
//#import "ff.h"
#import "EXFileStat.h"

NS_ASSUME_NONNULL_BEGIN


@protocol EXManagerDelegate <NSObject>

@required
-(BOOL) ex_readBlock:(uint64_t)lba count:(uint64_t)count buffer:(void*)buffer;
-(BOOL) ex_writeBlock:(uint64_t)lba count:(uint64_t)count buffer:(void*)buffer;
-(int)ex_init;
@end


@interface EXManager : NSObject



+(instancetype)defaultManager;
@property (weak, nonatomic, nullable) id <EXManagerDelegate> delegate;

@property (assign, nonatomic)NSInteger fat_type;


-(void)registerDelegate:(id<EXManagerDelegate>)delegate;
-(BOOL)mount;
-(void)unmount;

-(uint64_t)openfile:(NSString *)path opt:(unsigned char) mode;
-(int)closefile:(uint64_t)handle path:(NSString *)path;
-(uint64_t)gettot_sect:(void(^ _Nullable)(uint64_t tot_sect,uint64_t fre_sect,int ret))progressHandler;
-(int)makeDir:(NSString*)path;
-(uint64_t)getfilesize:(NSString*)path handle:(uint64_t)handle;
-(int)deletefile:(NSString*)path;
-(int64_t)opendir:(NSString *)path;
-(int)closedir:(NSString*)path;
-(int)readdir:(EXFileStat*)stat path:(NSString*)path;

-(EXFileStat*)getFileInfo:(NSString*)path;
-(NSMutableArray *)listDir:(NSString *)path;

-(int)renamefile:(NSString*)oldpath topath:(NSString*)newpath;

-(int)seekfile:(uint64_t)hanlde pos:(uint64_t)pos path:(NSString*)path;
// 读文件内容，返回读入长度，-1表示读取失败
-(int)read:(uint8_t *)buffer length:(uint32_t)length path:(NSString*)path;

// 写文件内容，返回写入长度，-1表示写入失败
-(int)write:(uint8_t *)buffer length:(uint32_t)length path:(NSString*)path;

-(int)updateModifiedDate:(NSDate*)date path:(NSString *)sdpath;

// 加密文件夹
-(BOOL)encryptFolder:(NSString *)url;
// 解密文件夹
-(BOOL)decryptFolder:(NSString *)url;

-(BOOL)format:(BOOL)isFAT32 total:(uint64_t)space;







@end

NS_ASSUME_NONNULL_END
