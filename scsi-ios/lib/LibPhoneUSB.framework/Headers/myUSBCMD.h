//
//  myUSBCMD.h
//  TestEA_two
//
//  Created by macliu on 2023/5/9.
//

#ifndef myUSBCMD_h
#define myUSBCMD_h

#define CBW_SIGNATURE 0x43425355
#define CSW_SIGNATURE 0x53425355
#define CRW_SIGNATURE 0x52425355


#define SCSI_CMD_TEST_UNIT_READY                 0x00
#define SCSI_CMD_REQUEST_SENSE                   0x03
#define SCSI_CMD_INQUIRY                         0x12
#define SCSI_CMD_READ_CAPACITY                   0x25
#define SCSI_CMD_READ_10                         0x28
#define SCSI_CMD_WRITE_10                        0x2A
#define SCSI_CMD_SEEK_10                         0x2B
#define SCSI_CMD_SHA204                          0xC7


#pragma pack(1)

typedef struct {
    uint32_t signature;
    uint32_t tag;
}CRW;




struct myUSBCBW{
    
    uint32_t dCBWSignature;
    uint32_t dCBWTag;                // Command Block 的唯一标识
    uint32_t dCBWDataTransferLength;
    uint8_t   bmCBWFlags;
    uint8_t   bCBWLUN;
    uint8_t   bCBWCBLength;
    uint8_t   au8Data[16];
   // uint8_t   other[480];
    
   /* uint32_t dCBWSignature;          // 固定值 0x43425355
    uint32_t dCBWTag;                // Command Block 的唯一标识
    uint32_t dCBWDataTransferLength; // 数据传输长度
        uint8_t  bmCBWFlags;             // 数据传输方向（IN/OUT）
        uint8_t  bCBWLUN;                // 逻辑单元号
        uint8_t  bCBWCBLength;           // SCSI 命令的长度
        uint8_t  CBWCB[16];              // SCSI 命令*/
    
    
    
};

 struct  my_CSW{
  uint32_t dSignature;  //csw标志,为字符 usbs
  uint32_t dTag;    //命令状态标签,从cbw的标签中来
  uint32_t dDataResidue;    //命令完成时的完成字节数
  uint8_t  bStatus; //命令执行状态 00代表执行成功
};



#pragma pack()





#endif /* myUSBCMD_h */





