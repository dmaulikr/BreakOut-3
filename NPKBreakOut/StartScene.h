//
//  StartScene.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameSaveFile.h"

@interface StartScene : SKScene <UIGestureRecognizerDelegate>

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIView *dataView;

-(void)startMainSceneWithSaveFile:(GameSaveFile *)saveFile;
-(void)startEditSceneWithSaveFile:(GameSaveFile *)saveFile;
-(void)createSceneContents;


@end
