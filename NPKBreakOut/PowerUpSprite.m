//
//  PowerUpSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "PowerUpSprite.h"

@interface PowerUpSprite ()

@end

@implementation PowerUpSprite

-(PowerUpSprite *)initWithLocation:(CGPoint)location type:(NSString *)type name:(NSString*)name
{
    if (self == [super initWithImageNamed:@"powerUpCircle.png"]) {
        self.position = location;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.friction = 0.0;
        //testing
        self.physicsBody.linearDamping = 0.0;
        self.physicsBody.restitution = 1.0;

        //self.physicsBody.dynamic = NO;
        self.name = name;
        self.type = type;
        [self createAnimation];
    }
    return self;
}

-(void)createAnimation
{
    SKSpriteNode *letterP = [SKSpriteNode spriteNodeWithImageNamed:@"powerUpP.png"];
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.4],
                                           [SKAction fadeInWithDuration:0.4]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [letterP runAction:blinkForever];
    [self addChild:letterP];
    
    SKAction *moveDown = [SKAction moveToY:0.0 duration:5];
    [self runAction:moveDown];
}

@end
