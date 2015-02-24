//
//  BallSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "BallSprite.h"

@interface BallSprite ()

@end

@implementation BallSprite


-(BallSprite *)initWithLocation:(CGPoint)location currentSize:(NSString *)currentSize status:(NSString *)status name:(NSString *)name
{
    if (self == [super initWithImageNamed:@"ball.png"]) {
        
        self.name        = name;
        self.position    = location;
        self.currentSize = currentSize;
        
        self.physicsBody                               = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
        self.physicsBody.friction                      = 0.0;
        self.physicsBody.restitution                   = 1.0;
        self.physicsBody.linearDamping                 = 0.0;
        self.physicsBody.allowsRotation                = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        [self updateSelf];
        
    }
    return self;
}

-(void)updateSelf
{
    [super updateSizeWithImageNamed:@"ball.png" currentSize:self.currentSize];
    
}


@end
