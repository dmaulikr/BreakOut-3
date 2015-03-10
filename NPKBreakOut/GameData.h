//
//  GameData.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject

@property (nonatomic) NSArray *blocks;
@property (nonatomic) NSArray *paddles;
@property (nonatomic) NSArray *balls;

-(instancetype)sharedGameData;
-(void)reset;


@end
