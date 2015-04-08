//
//  GameSaveFile.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/26/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameSaveFile.h"
#import "Constants.h"

static NSString * const gameDataBallsKey    = @"balls";
static NSString * const gameDataBlocksKey   = @"blocks";
static NSString * const gameDataPaddlesKey  = @"paddles";
static NSString * const gameDataPowerUpsKey = @"powerUps";
static NSString * const saveFileNameKey     = @"saveKey";

@implementation GameSaveFile


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"init with coder game save file");
    self = [self init];
    if (self) {
        
        if ([aDecoder decodeObjectForKey:saveFileNameKey]) {
            self.saveFileName = [aDecoder decodeObjectForKey:saveFileNameKey];
            NSLog(@"loaded save file name %@", self.saveFileName);
            
        }
        
        if ([aDecoder decodeObjectForKey:gameDataBlocksKey]) {
            self.blocks = [aDecoder decodeObjectForKey:gameDataBlocksKey];
            NSLog(@"save file decoded %lu number of blocks", self.blocks.count);
        } else {
            NSLog(@"save file couldnt decode blocks");
        }
        
        if ([aDecoder decodeObjectForKey:gameDataBallsKey]) {
            self.balls = [aDecoder decodeObjectForKey:gameDataBallsKey];
            NSLog(@"save file decoded balls");
        } else {
            NSLog(@"save file couldn't load balls");
        }

        //self.paddles = [aDecoder decodeObjectForKey:gameDataPaddlesKey];
        //self.powerUps = [aDecoder decodeObjectForKey:gameDataPowerUpsKey];
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        NSLog(@"game Save Reset");
        self.saveFileName = @"";
        self.balls   = [[NSMutableArray alloc] init];
        self.blocks  = [[NSMutableArray alloc] init];
        self.paddles = [[NSMutableArray alloc] init];
        self.powerUps = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)reset
{
    NSLog(@"game Save Reset");
    self.saveFileName = @"";
    self.balls   = [[NSMutableArray alloc] init];
    self.blocks  = [[NSMutableArray alloc] init];
    self.paddles = [[NSMutableArray alloc] init];
    self.powerUps = [[NSMutableArray alloc] init];
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"encoding save %@", self.saveFileName);
    [aCoder encodeObject:self.saveFileName forKey:saveFileNameKey];
    [aCoder encodeObject:self.balls    forKey:gameDataBallsKey];
    [aCoder encodeObject:self.blocks   forKey:gameDataBlocksKey];
    [aCoder encodeObject:self.paddles  forKey:gameDataPaddlesKey];
    [aCoder encodeObject:self.powerUps forKey:gameDataPowerUpsKey];
}

@end
