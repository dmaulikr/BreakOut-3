//
//  PaddleSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "PaddleSprite.h"


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
        
        self.physicsBody                               = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.restitution                   = 0.1;
        self.physicsBody.friction                      = 0.4;
        self.physicsBody.dynamic                       = NO;
        [self updateSelf];
        
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
    [super updateSizeWithImageNamed:@"paddle.png" currentSize:self.currentSize];
    
}

@end
