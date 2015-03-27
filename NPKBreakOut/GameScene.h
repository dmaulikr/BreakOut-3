//
//  GameScene.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 2/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameSaveFile.h"

@interface GameScene : SKScene

-(SKNode *)createNodeTree;
-(GameSaveFile *)setupSaveFile:(GameSaveFile *)saveFile;

@end
