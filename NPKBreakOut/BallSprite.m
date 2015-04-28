//
//  BallSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "BallSprite.h"
#import "Constants.h"

static NSString * const positionKey     = @"position";
static NSString * const currentSizeKey  = @"currentSize";
static NSString * const nameKey         = @"name";
static NSString * const statusKey       = @"status";
static NSString * const velocityDxKey     = @"velocityDx";
static NSString * const velocityDyKey     = @"velocityDy";


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
        //self.physicsBody.categoryBitMask               = ballCategory;
                
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        BallSprite *ball = [[BallSprite alloc] initWithLocation:[[aDecoder decodeObjectForKey:positionKey] CGPointValue]
                                                    currentSize:[aDecoder decodeObjectForKey:currentSizeKey]
                                                         status:[aDecoder decodeObjectForKey:statusKey]
                                                           name:[aDecoder decodeObjectForKey:nameKey]];
        CGVector vector = CGVectorMake([aDecoder decodeFloatForKey:velocityDxKey], [aDecoder decodeFloatForKey:velocityDyKey]);
        ball.physicsBody.velocity = vector;
        self = ball;
        //NSLog(@"init with coder ball decoding %@", self.name);
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //NSLog(@"encoding ball %@", self.name);
    [aCoder encodeObject:self.name forKey:nameKey];
    [aCoder encodeObject:self.currentSize forKey:currentSizeKey];
    [aCoder encodeObject:self.status forKey:statusKey];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:positionKey];
    [aCoder encodeFloat:self.physicsBody.velocity.dx forKey:velocityDxKey];
    [aCoder encodeFloat:self.physicsBody.velocity.dy forKey:velocityDyKey];
    

}
-(void)updateSelf
{
    
}


-(void)updateSize
{
    
    int testWidth = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"].size.width;
    int selfWidth = self.frame.size.width;
    BOOL isSizeNormal = [self.currentSize isEqualToString:@"normal"];
    BOOL isSizeSmall = [self.currentSize isEqualToString:@"small"];
    BOOL isSizeBig = [self.currentSize isEqualToString:@"big"];
    
    
    if (isSizeNormal) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ correct size", self.name);
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@too small", self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ too big", self.name);
        }
    }
    
    if (isSizeSmall) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ one too big", self.name);
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@ correct size",self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ two too big",self.name);
        }
    }
    
    if (isSizeBig) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ one too small growing!!", self.name);
            SKAction *grow = [SKAction scaleBy:2 duration:1];
            SKAction *wait = [SKAction waitForDuration:7];
            SKAction *shrink = [SKAction scaleBy:0.5 duration:1];
            SKAction *toNormal = [SKAction runBlock:^{
                self.currentSize = @"normal";
            }];
            SKAction *growWaitShrink = [SKAction sequence:@[grow, wait, shrink, toNormal]];
            [self runAction:growWaitShrink];
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@ two too small",self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ correct size",self.name);
        }
        
    }
    
}


@end
