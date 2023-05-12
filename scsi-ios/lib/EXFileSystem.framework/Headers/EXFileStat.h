//
//  FileStat.h
//  EXFileSystem
//
//  Created by macliu on 2023/5/12.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXFileStat : NSObject


@property (assign, nonatomic) NSUInteger fsize;

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *fname;
@property (assign, nonatomic) NSInteger isdir;
@property (assign, nonatomic) unsigned char    fattrib;        /* File attribute */


@property (strong, nonatomic) NSString *lfname;

@property (strong, nonatomic) NSString *extname;
@property (strong, nonatomic) NSString *fullpath;
@property (strong, nonatomic) NSString *dir;
@property (assign, nonatomic) NSInteger how;

@property (strong, nonatomic) NSURL *nailurl;
@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) NSInteger isiphonefile;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) NSInteger isass;

@property (strong, nonatomic) PHAsset *phasset;
@property (assign, nonatomic) NSInteger isphass;

@property (strong, nonatomic) NSString *day;


@end

NS_ASSUME_NONNULL_END
