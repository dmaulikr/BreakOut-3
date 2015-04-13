//
//  GridSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/13/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GridSprite.h"
#import "Constants.h"

@interface GridSprite ()

@end

@implementation GridSprite

-(instancetype)init
{
    if (self = [super initWithTexture:[SKTexture textureWithImageNamed:@"Grid.png"] color:nil size:CGSizeMake(50, 50)]) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = NO;
        self.name = gridButtonName;
        self.isPressed = NO;
        
    }
    return self;
    
}

-(void)changeStatus
{
    if (self.isPressed) {
        self.isPressed = NO;
        self.texture = [SKTexture textureWithImageNamed:@"Grid.png"];
    } else {
        self.isPressed = YES;
        self.texture = [SKTexture textureWithImageNamed:@"GridRed.png"];
    }
}

@end
