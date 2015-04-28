//
//  PowerUpButton.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/20/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "PowerUpButton.h"
#import "Constants.h"

@implementation PowerUpButton

- (instancetype)init
{
    self = [super initWithTexture:[SKTexture textureWithImageNamed:@"powerUpRed.png"]];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.dynamic = NO;
        self.name = powerUpButtonName;
        self.isPressed = NO;
    }
    return self;
}


-(void)changeStatus
{
    if (self.isPressed) {
        self.isPressed = NO;
        self.colorBlendFactor = 0;
    } else {
        self.isPressed = YES;
        self.color = [UIColor blueColor];
        self.colorBlendFactor = 0.5;
    }
}


@end
