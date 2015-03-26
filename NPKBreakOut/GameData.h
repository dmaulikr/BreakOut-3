//
//  GameData.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartScene.h"


@interface GameData : NSObject <NSCoding>

@property (nonatomic) NSMutableArray *blocks;
@property (nonatomic) NSMutableArray *paddles;
@property (nonatomic) NSMutableArray *balls;
@property (nonatomic) NSMutableArray *powerUps;
@property (nonatomic) NSString *saveFileName;
@property (nonatomic) StartScene *startScene;

+(instancetype)sharedGameData;
-(void)reset;
-(void)resaveGameData;
-(void)saveWithFileName:(NSString *)fileName;
-(id)initWithFileName:(NSString *)fileName;
-(BOOL)doesSaveFileExist:(NSString *)fileName;
-(BOOL)deleteSaveFile:(NSString *)fileName;


@end
