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


@implementation GameData

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"init with coder a decoder");

    if (self = [self initWithFileName:@""]) {
        self.balls  = [aDecoder decodeObjectForKey:gameDataBallsKey];
        self.blocks = [aDecoder decodeObjectForKey:gameDataBlocksKey];
        self.paddles = [aDecoder decodeObjectForKey:gameDataPaddlesKey];
        self.powerUps = [aDecoder decodeObjectForKey:gameDataPowerUpsKey];
    }
    return self;
    
}



-(id)initWithFileName:(NSString *)fileName
{

    [self reset];
    if (self = [super init]) {
        if (fileName) {
            NSLog(@"GameData initWithFilename there is a filename");
            
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

+(NSString*)filePath
{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];

    return filePath;
}

+(instancetype)loadInstance
{
 
    NSLog(@"loadInstance");
    NSData * decodedData = [NSData dataWithContentsOfFile:[GameData filePath]];
    if (decodedData) {
        NSLog(@"loading data");
        GameData *gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    } else {
        NSLog(@"load instance no data to load");
    }
    return [[GameData alloc] init];
}

-(void)save
{
    [NSKeyedArchiver archiveRootObject:self toFile:[GameData filePath]];
    //[encodedData writeToFile:[GameData filePath] atomically:YES];
}

-(void)reset
{

    NSLog(@"gamedata Reset");
    self.balls   = [[NSMutableArray alloc] init];
    self.blocks  = [[NSMutableArray alloc] init];
    self.paddles = [[NSMutableArray alloc] init];
    self.powerUps = [[NSMutableArray alloc] init];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"encoding GameData");

    [aCoder encodeInteger:1 forKey:@"one"];
    //[aCoder encodeObject:self.balls    forKey:gameDataBallsKey];
    //[aCoder encodeObject:self.blocks   forKey:gameDataBlocksKey];
    //[aCoder encodeObject:self.paddles  forKey:gameDataPaddlesKey];
    //[aCoder encodeObject:self.powerUps forKey:gameDataPowerUpsKey];
}




@end
