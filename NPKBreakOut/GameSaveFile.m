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
static NSString * const saveFileKey         = @"saveKey";

@implementation GameSaveFile


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.saveFileName = [aDecoder decodeObjectForKey:saveFileKey];
        if ([aDecoder decodeObjectForKey:saveFileKey]) {
            NSLog(@"loaded save file name %@", self.saveFileName);
        }
        
        self.balls  = [aDecoder decodeObjectForKey:gameDataBallsKey];
        self.blocks = [aDecoder decodeObjectForKey:gameDataBlocksKey];
        if (!self.blocks) {
            NSLog(@"no blocks");
        } else {
            NSLog(@"loaded blocks count %lu  ", self.blocks.count);
        }
        self.paddles = [aDecoder decodeObjectForKey:gameDataPaddlesKey];
        self.powerUps = [aDecoder decodeObjectForKey:gameDataPowerUpsKey];
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self reset];
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
    [aCoder encodeObject:self.saveFileName forKey:saveFileKey];
    [aCoder encodeObject:self.balls    forKey:gameDataBallsKey];
    [aCoder encodeObject:self.blocks   forKey:gameDataBlocksKey];
    [aCoder encodeObject:self.paddles  forKey:gameDataPaddlesKey];
    [aCoder encodeObject:self.powerUps forKey:gameDataPowerUpsKey];
}

@end
