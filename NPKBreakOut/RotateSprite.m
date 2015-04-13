//
//  RotateSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/9/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "RotateSprite.h"
#import "Constants.h"


static NSString * const rotateImageName = @"rotate.png";
static NSString * const outlinedRotateImageName   = @"rotateOutline.png";

@implementation RotateSprite

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size name:(NSString *)name
{
    if (self = [super initWithTexture:[SKTexture textureWithImageNamed:rotateImageName]
                                color:color
                                 size:size]) {
        if (color) {
            self.colorBlendFactor = 1;
        }
        self.name = name;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.dynamic = NO;
        //self.anchorPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 1);
        self.isPressed = NO;
    }
    return self;
}

-(void)changeStatus
{
    if (self.isPressed) {
        [self stopRotating];
    } else {
        [self startRotating];
    }
}

-(void)startRotating
{
    self.isPressed = YES;
    [self setTexture:[SKTexture textureWithImageNamed:outlinedRotateImageName]];
    SKAction *rotate = [SKAction rotateByAngle:-2*M_PI duration:1];
    SKAction *wait = [SKAction waitForDuration:1];
    SKAction *rotateAndWait = [SKAction sequence:@[rotate, wait]];
    SKAction *rotateForever = [SKAction repeatActionForever:rotateAndWait];
    [self runAction:rotateForever];
}

-(void)stopRotating
{
    NSLog(@"stop rotate");
    self.isPressed = NO;
    [self removeAllActions];
    [self setTexture:[SKTexture textureWithImageNamed:rotateImageName]];
    
    
}

@end
