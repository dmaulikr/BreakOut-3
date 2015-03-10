//
//  GameData.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameData.h"

@implementation GameData

+(instancetype)sharedGameData
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)reset
{
    self.balls   = [[NSMutableArray alloc] init];
    self.blocks  = [[NSMutableArray alloc] init];
    self.paddles = [[NSMutableArray alloc] init];
}




@end
