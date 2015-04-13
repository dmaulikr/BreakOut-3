//
//  GridSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/13/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GridSprite : SKSpriteNode


@property (nonatomic) BOOL isPressed;


-(void)changeStatus;

@end
