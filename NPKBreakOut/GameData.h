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

@property (nonatomic) StartScene *startScene;



+(instancetype)sharedGameData;
-(void)reset;
-(void)resaveGameData;
-(id)initWithFileName:(NSString *)fileName;
-(void)saveWithFileName:(NSString *)fileName;
-(BOOL)doesSaveFileExist:(NSString *)fileName;
-(BOOL)deleteSaveFile:(NSString *)fileName;


@end
