//
//  PaddleSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "PaddleSprite.h"
#import "Constants.h"
#import "RotateSprite.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)



static NSString *positionKey = @"position";
static NSString *statusKey   = @"status";
static NSString *nameKey     = @"name";
static NSString *currentSizeKey = @"currentSizeKey";


@interface PaddleSprite ()


@end

@implementation PaddleSprite

-(PaddleSprite *)initWithCurrentSize:(NSString *)currentSize position:(CGPoint)position status:(NSString *)status name:(NSString *)name
{
    if (self = [super initWithImageNamed:@"paddle.png"]) {
        
        self.name        = name;
        self.position    = position;
        self.currentSize = currentSize;
        self.status      = status;
        self.isMoving = NO;
        
        
        self.physicsBody                               = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.restitution                   = 0;
        self.physicsBody.friction                      = 0.4;
        self.physicsBody.dynamic                       = NO;
        self.physicsBody.categoryBitMask               = paddleCategory;
        self.physicsBody.allowsRotation                = NO;
        self.orientation = orientationHorizontal;
                
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:[aDecoder decodeObjectForKey:currentSizeKey]
                                                                position:[[aDecoder decodeObjectForKey:positionKey] CGPointValue]
                                                                  status:[aDecoder decodeObjectForKey:statusKey]
                                                                    name:[aDecoder decodeObjectForKey:nameKey]];
        self = paddle;

    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.position] forKey:positionKey];
    [aCoder encodeObject:self.status forKey:statusKey];
    [aCoder encodeObject:self.name forKey:nameKey];
    [aCoder encodeObject:self.currentSize forKey:currentSizeKey];

}

-(void)updateSelf
{
    RotateSprite *rotatePoint = (RotateSprite *)[self childNodeWithName:rotatePointName];
    
    if (self.isRotatable) {
        if (!rotatePoint) {
            [self createRotatePoint];
        }
    } else {
        if (rotatePoint) {
            [rotatePoint removeFromParent];
        }
    }
    

}

-(void)createRotatePoint
{
    RotateSprite *rotatePoint = [[RotateSprite alloc] initWithColor:[UIColor blackColor]
                                                               size:CGSizeMake(20, 20)
                                                               name:rotatePointName];
    rotatePoint.position = CGPointMake(0, 1.5);
    
    [self addChild:rotatePoint];
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

-(void)adjustRotationWithTouches:(NSSet *)touches
{

    [self runAction:[SKAction rotateByAngle:-M_PI/4 duration:0]completion:^{
        //NSLog(@"after rotation %f", self.zRotation);
        //NSLog(@"rounded rotate %f", roundf(self.zRotation *100)/100);
        //NSLog(@"rounded pie %f", -roundf((M_PI/2) * 100)/100);
        

    }];
    

}

@end
