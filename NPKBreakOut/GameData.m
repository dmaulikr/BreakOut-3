//
//  GameData.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameData.h"
#import "BlockSprite.h"
#import "GameSaveFile.h"
#import "Constants.h"

@implementation GameData

-(instancetype)init
{
    //NSLog(@"gamedata init");
    self = [super init];
    if (self) {
        NSString *path = [GameData filePathWithName:@""];
        self.saveFile = [[GameSaveFile alloc] init];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return self;
}

-(GameSaveFile *)loadSaveFileWithFileName:(NSString *)fileName
{
    NSData *decodedData = [NSData dataWithContentsOfFile:[GameData filePathWithName:fileName]];
    
    if (decodedData) {
         self.saveFile = (GameSaveFile *)[NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    }
    
    return self.saveFile;
}

-(void)deleteSaveFileNamed:(NSString *)fileName
{
    NSString *path = [GameData filePathWithName:fileName];
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (!success || error) {
        NSLog(@"couldnt delete %@", fileName);
    } else {
        NSLog(@"deleted %@", fileName);

    }
    
}


-(void)archiveSaveFile
{
    NSString *filePath = [GameData filePathWithName:self.saveFile.saveFileName];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self.saveFile toFile:filePath];
    
    if (success) {
        NSLog(@"saved %@ ", self.saveFile);
    } else {
        NSLog(@"couldnt save");
    }
    
}

+(instancetype)sharedGameData
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameData alloc] init];
    });
    
    return sharedInstance;
}

+(NSString*)filePathWithName:(NSString *)fileName
{
    
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"/gameData"];
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];

    return filePath;
}

-(NSMutableArray *)loadSaveFiles
{
    NSString *url = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:saveFileDirectory];
    NSMutableArray *files;
    NSArray *filesUrl = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url error:Nil];
    if (filesUrl) {
         files = (NSMutableArray *)filesUrl;
    }
    return files;
}

-(BOOL)doesSaveFileExist:(NSString *)fileName;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[GameData filePathWithName:fileName]];
}





@end
