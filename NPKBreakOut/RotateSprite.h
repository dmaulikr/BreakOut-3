//
//  RotateSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/9/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface RotateSprite : SKSpriteNode

@property (nonatomic) BOOL isPressed;

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size name:(NSString *)name;
-(void)changeStatus;

@end
