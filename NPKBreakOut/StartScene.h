//
//  StartScene.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StartScene : SKScene <UIGestureRecognizerDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableView;

-(void)startMainScene;
-(void)startEditScene;

@end
