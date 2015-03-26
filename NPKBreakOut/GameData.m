//
//  GameData.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameData.h"
#import "BlockSprite.h"

static NSString * const gameDataBallsKey    = @"balls";
static NSString * const gameDataBlocksKey   = @"blocks";
static NSString * const gameDataPaddlesKey  = @"paddles";
static NSString * const gameDataPowerUpsKey = @"powerUps";
static NSString * const saveFileKey = @"saveKey";


@implementation GameData

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"GameData init with coder a decoder");
    [self reset];

    if (self) {
        NSLog(@"assigning decoded values");
        self.saveFileName = [aDecoder decodeObjectForKey:saveFileKey];
        if ([aDecoder decodeObjectForKey:saveFileKey]) {
            NSLog(@"de %@", self.saveFileName);
        }
        
        self.balls  = [aDecoder decodeObjectForKey:gameDataBallsKey];
        self.blocks = [aDecoder decodeObjectForKey:gameDataBlocksKey];
        if (!self.blocks) {
            NSLog(@"no blocks");
        } else {
            NSLog(@"blocks count %lu  ", self.blocks.count);
        }
        self.paddles = [aDecoder decodeObjectForKey:gameDataPaddlesKey];
        self.powerUps = [aDecoder decodeObjectForKey:gameDataPowerUpsKey];
    }
    return self;
    
}

-(BOOL)doesSaveFileExist:(NSString *)fileName;
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[GameData filePathWithName:fileName]];
}

-(BOOL)deleteSaveFile:(NSString *)fileName
{
    NSString *path = [GameData filePathWithName:fileName];
    NSLog(@"deleting %@",path);
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (!success || error) {
        return NO;
    }
    return YES;
    
}

-(instancetype)init
{
    NSLog(@"GameData init");
    self = [super init];
    if (self) {
        NSString *path = [GameData filePathWithName:@""];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"no file creating folder");
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
            
        } else {
            NSLog(@"file alreay exists");
        }
        [self reset];
    }
    return self;
}



-(id)initWithFileName:(NSString *)fileName
{

    [self reset];
    if (self = [super init]) {
        if (fileName) {
            NSLog(@"GameData initWithFilename there is a filename");
            self = [self loadInstanceWithFileName:fileName];
            
        } else {
            NSLog(@"GameData initWithFileNAme no fileName");
        }
    }
    return self;
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



-(instancetype)loadInstanceWithFileName:(NSString *)fileName
{
    NSLog(@"loadInstance");
    
    NSData * decodedData = [NSData dataWithContentsOfFile:[GameData filePathWithName:fileName]];
    GameData *gameData = self;
    
    if (decodedData) {
        NSLog(@"loading data");
        gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    } else {
        NSLog(@"load instance no data to load");
    }
    
    return gameData;
}

-(void)resaveGameData
{
    NSString *filePath = [GameData filePathWithName:self.saveFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:[GameData filePathWithName:self.saveFileName]];
        if (success) {
            NSLog(@"resaved %@",self.saveFileName);
            
        } else {
            //NSLog(@"bad");
        }
    }
}

-(void)saveWithFileName:(NSString *)fileName
{

    
    NSString *filePath = [GameData filePathWithName:fileName];
    //NSLog(@"data save with file %@", filePath);
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    
    
    if (success) {
        NSLog(@"saved %@ to location %@", fileName, filePath);
    } else {
        NSLog(@"couldnt save");
    }
    
    
    //[encodedData writeToFile:[GameData filePath] atomically:YES];
}

-(void)reset
{

    NSLog(@"gamedata Reset reset reset reset");
    self.saveFileName = @"";
    self.startScene = nil;
    self.balls   = [[NSMutableArray alloc] init];
    self.blocks  = [[NSMutableArray alloc] init];
    self.paddles = [[NSMutableArray alloc] init];
    self.powerUps = [[NSMutableArray alloc] init];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //NSLog(@"encoding GameData");

    //[aCoder encodeInteger:1 forKey:@"one"];
    NSLog(@"encoding save %@", self.saveFileName);
    [aCoder encodeObject:self.saveFileName forKey:saveFileKey];
    //[aCoder encodeObject:self.balls    forKey:gameDataBallsKey];
    [aCoder encodeObject:self.blocks   forKey:gameDataBlocksKey];
    //[aCoder encodeObject:self.paddles  forKey:gameDataPaddlesKey];
    //[aCoder encodeObject:self.powerUps forKey:gameDataPowerUpsKey];
}




@end
