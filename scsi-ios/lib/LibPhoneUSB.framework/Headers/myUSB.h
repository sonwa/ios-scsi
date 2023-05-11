//
//  myUSB.h
//  LibMyUSBOne
//
//  Created by macliu on 2023/4/28.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

//typedef unsigned long long uint64;
//typedef signed long long   int64;
//typedef unsigned int uint32;

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus


@interface myUSB : NSObject


+ (instancetype _Nonnull )shareInstance;

- (void)setAccessory:(nullable EAAccessory *)accessory forProtocol:(NSString *_Nonnull)protocol;


@end


BOOL Disk_OpenSession(void);
BOOL Disk_CloseSession(void);

int Disk_GetDiskCapacity(int64_t * _Nonnull pDiskCapacity);

int Disk_scsiRead(unsigned long long lba, unsigned char * _Nonnull buffer, unsigned int sector_count);
int Disk_scsiWrite(unsigned long long lba, unsigned char * _Nonnull buffer, unsigned int sector_count);




NSString* _Nullable Disk_LibVersion(void);






#ifdef __cplusplus
}
#endif //__cplusplus


