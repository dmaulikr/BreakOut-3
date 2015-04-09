//
//  GameData.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/10/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartScene.h"
#import "GameSaveFile.h"


@interface GameData : NSObject

@property (nonatomic) StartScene *startScene;
@property (nonatomic) GameSaveFile *saveFile;

+(instancetype)sharedGameData;
-(GameSaveFile *)loadSaveFileWithFileName:(NSString *)fileName;

-(BOOL)doesSaveFileExist:(NSString *)fileName;
-(void)resetData;
-(void)archiveSaveFile;
-(void)deleteSaveFileNamed:(NSString *)fileName;
-(NSMutableArray *)loadSaveFiles;


@end
