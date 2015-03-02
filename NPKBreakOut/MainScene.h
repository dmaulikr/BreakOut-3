//
//  MainScene.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/12/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <UIKit/UIKit.h>
#import "GameScene.h"



@interface MainScene : GameScene <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>

-(instancetype)initWithSize:(CGSize)size Blocks:(NSArray*)blocks Balls:(NSArray*)balls AndPaddles:(NSArray*)paddles;

@end
