//
//  PaddleSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "PaddleSprite.h"


static NSString* ballCategoryName = @"ball";
static NSString* paddleCategoryName = @"paddle";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";

@interface PaddleSprite ()


@end

@implementation PaddleSprite

-(PaddleSprite *)initWithCurrentSize:(NSString *)currentSize status:(NSString *)status name:(NSString *)name
{
    if (self = [super initWithImageNamed:@"paddle.png"]) {
        
        self.name        = name;
        self.position    = CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), [[UIScreen mainScreen] bounds].size.height * .05);
        self.currentSize = currentSize;
        self.status      = status;
        
        self.physicsBody                               = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.restitution                   = 0.1;
        self.physicsBody.friction                      = 0.4;
        self.physicsBody.dynamic                       = NO;
        [self updateSelf];
        
    }
    return self;
}

-(void)updateSelf
{
    [super updateSizeWithImageNamed:@"paddle.png" currentSize:self.currentSize];
    
}

@end
