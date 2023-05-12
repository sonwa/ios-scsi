//
//  ViewController.m
//  scsi-ios
//
//  Created by macliu on 2023/5/11.
//

#import "ViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import <LibPhoneUSB/LibPhoneUSB.h>
#import <EXFileSystem/EXFileSystem.h>


@interface ViewController ()<EXManagerDelegate>

@property (nonatomic, strong) NSMutableArray *accessoryList;
@property (nonatomic, strong) EAAccessory *selectedAccessory;

@property (nonatomic, strong) NSArray *supportedProtocolsStrings;

@property (nonatomic,assign)BOOL isConnected;

@property (nonatomic,assign) NSInteger itype;

@property (nonatomic,strong)NSString *firmwareRevision;
@property (nonatomic,strong)NSString *firmname;
@property (nonatomic,strong)NSString *manufacturer;
@property (nonatomic,strong)NSString *modelNumber;

@property (nonatomic,strong)NSString *protocolString;

@property (nonatomic, strong) myUSB *musb;
@property (nonatomic, strong) EXManager *mfilesystem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    uint32_t dCBWTag = 0x80800000;
    
    dCBWTag++;
 
    
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    self.supportedProtocolsStrings = [mainBundle objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    

    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    _accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    _musb = [myUSB shareInstance];
    _mfilesystem = [EXManager defaultManager];
    _mfilesystem.delegate = self;
    
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
   
    _accessoryList = nil;
    _selectedAccessory = nil;
  //  [_eaSessionController closeSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 文件系统代理
-(BOOL) ex_readBlock:(uint64_t)lba count:(uint64_t)count buffer:(void*)buffer
{
    int iRet = Disk_scsiRead(lba, buffer, count);
    if(iRet == 0){
        return YES;
    }else{
        NSLog(@"写数据失败");
        return NO;
    }
}
-(BOOL) ex_writeBlock:(uint64_t)lba count:(uint64_t)count buffer:(void*)buffer
{
    int iRet = Disk_scsiWrite(lba, buffer, count);
    if (iRet==0) {
        return YES;
    }else{
        NSLog(@"读数据失败");
        return NO;
    }
}
-(int)ex_init
{
    if(self.isConnected){
        return 0;
    }else{
        return 1;
    }
}

#pragma mark - 打开数据收发通道
- (void)openMySession
{
    __weak typeof(self) weakSelf = self;
    //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    
    
    
    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
    NSArray<EAAccessory *> *accessArr = [manager connectedAccessories];
    NSLog(@"---配对---%@", accessArr);
    NSLog(@"---名字---%@", accessArr.firstObject.name);
  
    
    
    
    // watch for received data from the accessory
    weakSelf.accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    //  int usrI = -1;
    
    for (EAAccessory *access in weakSelf.accessoryList) {
        for (NSString *proStr in access.protocolStrings) {
            //  [info appendFormat:@"protocolString = %@\n", proStr];
            
            BOOL  matchFound = FALSE;
            for ( NSString *item in self.supportedProtocolsStrings)
            {
                if ([item compare: proStr] == NSOrderedSame)
                {
                    matchFound = TRUE;
                    NSLog(@"match found - protocolString %@", proStr);
                    self.selectedAccessory =access;
                    self.protocolString =proStr;
                    
                }
            }
            
            if (matchFound) {
                
                weakSelf.firmwareRevision =[access firmwareRevision];
                weakSelf.firmname         =[access name];
                weakSelf.manufacturer     =[access manufacturer];
                weakSelf.modelNumber      =[access modelNumber];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                 
                    
                    [weakSelf.musb  setAccessory:access forProtocol:proStr];
//
                  

                         if(Disk_OpenSession()){
                            
                              
                             uint64_t diskSize =0;
                             Disk_GetDiskCapacity(&diskSize);
                             
                             weakSelf.itype =2;//
                             
                             NSLog(@"数据通道开启成功啦");
                             weakSelf.isConnected = YES;
                         
                         }else{
                             NSLog(@"creating session failed");
                             
                             NSLog(@"数据通道开启失败");
                             weakSelf.isConnected = NO;
                         }
                     
                    
                });
               
                 
                 
                
            }
        }
    }
}
#pragma mark Internal

- (void)_accessoryDidConnect:(NSNotification *)notification {
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    [_accessoryList addObject:connectedAccessory];
    
    
    self.selectedAccessory = connectedAccessory;//[_accessoryList objectAtIndex:row];
    NSArray *protocolStrings = [self.selectedAccessory protocolStrings];
    
    for(NSString *protocolString in protocolStrings)
    {
        if (_selectedAccessory)
        {
            BOOL  matchFound = FALSE;
            for ( NSString *item in self.supportedProtocolsStrings)
            {
                if ([item compare: protocolString] == NSOrderedSame)
                {
                    matchFound = TRUE;
                    NSLog(@"match found - protocolString %@", protocolString);
                    
                    self.protocolString =protocolString;
                    
                    
                }
            }
            
            if (matchFound) {
                
                _firmwareRevision =[connectedAccessory firmwareRevision];
                _firmname         =[connectedAccessory name];
                _manufacturer     =[connectedAccessory manufacturer];
                _modelNumber      =[connectedAccessory modelNumber];
                
                
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                   
            
                  
                    [weakSelf.musb  setAccessory:weakSelf.selectedAccessory forProtocol:protocolString];
                    
                    if( Disk_OpenSession()){
                        
                       
                        uint64_t diskSize =0;
                        Disk_GetDiskCapacity(&diskSize);
                        
                        
                        
                        self.itype =2;//
                        
                        NSLog(@"数据通道开启成功啦");
                        weakSelf.isConnected = YES;
                        // g_bIsSessionOpen =YES;
                        //  g_DiskbIsSessionOpen=g_bIsSessionOpen;
                    }else{
                        NSLog(@"creating session failed");
                        
                        NSLog(@"数据通道开启失败");
                        weakSelf.isConnected = NO;
                        
                        // g_bIsSessionOpen =NO;
                        // g_DiskbIsSessionOpen=g_bIsSessionOpen;
                    }
                    
                    
                    
                    
                    
                });
            }
        }
       
        
    }
    
}
- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    
    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    if (_selectedAccessory && [disconnectedAccessory connectionID] == [_selectedAccessory connectionID])
    {
       
        _selectedAccessory = nil;
      
        
        
    }
    
    int disconnectedAccessoryIndex = 0;
    for(EAAccessory *accessory in _accessoryList) {
        if ([disconnectedAccessory connectionID] == [accessory connectionID]) {
            break;
        }
        disconnectedAccessoryIndex++;
    }
    
    if (disconnectedAccessoryIndex < [_accessoryList count]) {
        
        EAAccessory *connectedAccessory =[_accessoryList objectAtIndex:disconnectedAccessoryIndex];
        
        
        NSString *eaAccessoryName = [connectedAccessory name];
        if (!eaAccessoryName || [eaAccessoryName isEqualToString:@""]) {
            eaAccessoryName = @"unknown";
        }
        
      
        NSLog(@"%@", [NSString stringWithFormat:@"%@已断开",eaAccessoryName]);
 
        _firmwareRevision =@"";
        _firmname         =@"";
        _manufacturer     =@"";
        _modelNumber      =@"";
        
        
        
        
        NSArray *protocolStrings = [connectedAccessory protocolStrings];
        for(NSString *protocolString in protocolStrings)
        {
            if([protocolString isEqualToString:@"com.sandisk.ixpandv10"]){
                Disk_CloseSession();
            }
               
     
            
        }
      
    
        self.isConnected = NO;
        
 
        if (disconnectedAccessoryIndex < _accessoryList.count) {
            [_accessoryList removeObjectAtIndex:disconnectedAccessoryIndex];
        }
  
    } else {
        NSLog(@"could not find disconnected accessory in accessory list");
    }
    
    
}

- (IBAction)toopen:(id)sender {
    //
    [self openMySession];
}
- (IBAction)toclose:(id)sender {
    //
    Disk_CloseSession();
}

- (IBAction)toread:(id)sender {
    //
    uint8_t* buf = malloc(512*10);
    memset(buf, 0x00, 512*10);
   int ret = Disk_scsiRead(0, buf, 1);
    if(ret == 0){
        NSLog(@"读取成功");
    }
    
}
- (IBAction)towrite:(id)sender {
    //
    uint8_t* buf = malloc(512*10);
    memset(buf, 0x00, 512*10);
    
    uint32_t nLen = 10;
    // fill buf with incrementing bytes;
    for(uint32_t i = 0; i < 512*nLen; i++) {
        buf[i] = (i & 0xFF);
    }
    int res = Disk_scsiWrite(0x3f80, buf, 2);
    if(res == 0){
        uint8_t* readbuf = malloc(512*10);
        memset(readbuf, 0x00, 512*10);
        Disk_scsiRead(0x3f80, readbuf, 2);
        if( memcmp(readbuf, buf, 512*2)) {
            NSLog(@"error");
        }
        else {
            NSLog(@"ok");
           
        }
        free(readbuf);
    }
    free(buf);
    
}
- (IBAction)tofilesystem:(id)sender {
    
    if(!self.isConnected){
        NSLog(@"未检测到设备");
        return;
    }
    //1
    BOOL res = [_mfilesystem mount];
    if(!res){
        NSLog(@"文件系统加载失败");
        return;
    }
    
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    [_mfilesystem gettot_sect:^(uint64_t tot_sect, uint64_t fre_sect, int ret) {
        
        if(ret==0){
            double TOL=tot_sect*1.0f*512/1024/1024/1024;
            double fr=fre_sect*1.0f*512/1024/1024/1024;
            NSLog(@"%@",[NSString stringWithFormat:@"设备总空间：%.2f G\r\n可用空间：%.2f G。\r\n", TOL,fr]);
            
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableArray * arr  =[_mfilesystem listDir:@"0:"];
    //文件数
    for(int i=0;i<arr.count;i++){
        EXFileStat *mode = arr[i];
        NSLog(@"%@", [NSString stringWithFormat:@"%@------,%@",mode.fname,mode.date ]);
    }
    NSLog(@"读取完成");
    
    
    
    
    
    
    
    
    
    [_mfilesystem unmount];
    
}

@end
