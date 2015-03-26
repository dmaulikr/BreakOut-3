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
static NSString * const saveFileKey = @"saveKey";

@implementation GameSaveFile


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        <#statements#>
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        
    }
}





-(void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
