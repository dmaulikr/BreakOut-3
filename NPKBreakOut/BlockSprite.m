//
//  BlockSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "BlockSprite.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)


static double editPointRadius = 7.5;

@interface BlockSprite ()


@end

@implementation BlockSprite

-(SKSpriteNode *)initWithLocation:(CGPoint)   location
                        hitPoints:(int)       hitPoints
                             name:(NSString *)name
                       hasPowerup:(BOOL)      hasPowerup
                      currentSize:(NSString *)currentSize
                     canBeEdited:(BOOL)       canBeEdited
{
    if (self = [super initWithImageNamed:@"block.png"]) {
        
        self.position                   = location;
        self.name                       = name;
        self.physicsBody                = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.friction       = 0.0;
        self.physicsBody.dynamic        = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        self.currentSize = currentSize;
        self.hitPoints   = hitPoints;
        self.hasPowerup  = hasPowerup;
        self.canBeEdited = canBeEdited;

        [self updateSelf];
        
    }
    return self;
}

-(void)updateSelf
{
    if (self.hitPoints == 3) {
        
        self.color            = [UIColor redColor];
        self.colorBlendFactor = 0.9;
        
    } else if (self.hitPoints == 2) {
        
        self.colorBlendFactor = 0.4;
        
    } else {
        
        self.colorBlendFactor = 0.0;
        
    }
    
    if (self.canBeEdited) {
        
        if (self.isEditable && self.children.count != 2) {
            
            [self makeSelfEditable];
            
        } else if (!self.isEditable && self.children.count != 1) {

            [self makeSelfUneditable];
            
        }
    }
    
}

-(void)makeSelfUneditable
{
    [self removeAllChildren];
    
    self.physicsBody.dynamic = NO;
    self.isEditable          = NO;
    
    //[self addChild:[self createMovePoint]];

}

-(void)makeSelfEditable
{

    self.isEditable          = YES;
    self.physicsBody.dynamic = NO;
    
    [self removeAllChildren];
    
    [self addChild:[self createEditPointTopLeft]];
    [self addChild:[self createRotatePoint]];
    

}

-(SKShapeNode *)createRotatePoint
{
    SKShapeNode *rotatePoint = [SKShapeNode shapeNodeWithCircleOfRadius:editPointRadius];
    
    rotatePoint.position            = CGPointMake(0, 0);
    rotatePoint.name                = @"rotatePoint";
    rotatePoint.physicsBody         = [SKPhysicsBody bodyWithCircleOfRadius:rotatePoint.frame.size.height/2];
    rotatePoint.physicsBody.dynamic = NO;
    rotatePoint.zPosition           = 0.5;
    
    rotatePoint.lineWidth   = 0.01;
    rotatePoint.fillColor   = [SKColor greenColor];
    rotatePoint.strokeColor = [SKColor whiteColor];
    rotatePoint.glowWidth   = 0.0001;
    
    return  rotatePoint;
}

-(SKShapeNode *)createEditPointTopLeft
{
    SKShapeNode *editPointTopLeft = [SKShapeNode shapeNodeWithCircleOfRadius:editPointRadius];
    
    editPointTopLeft.position            = CGPointMake(0 - self.frame.size.width/2,self.frame.size.height/2 );
    editPointTopLeft.name                = @"editPointTopLeft";
    editPointTopLeft.physicsBody         = [SKPhysicsBody bodyWithCircleOfRadius:editPointTopLeft.frame.size.height/2];
    editPointTopLeft.physicsBody.dynamic = NO;
    editPointTopLeft.zPosition           = 0.5;
    
    editPointTopLeft.lineWidth   = 0.01;
    editPointTopLeft.fillColor   = [SKColor redColor];
    editPointTopLeft.strokeColor = [SKColor whiteColor];
    editPointTopLeft.glowWidth   = 0.0001;
    
    return editPointTopLeft;
}

-(SKShapeNode *)createMovePoint
{
    SKShapeNode *movePoint = [SKShapeNode shapeNodeWithCircleOfRadius:editPointRadius];
    
    movePoint.position            = CGPointMake(0, -self.frame.size.height/2);
    movePoint.name                = @"movePoint";
    movePoint.physicsBody         = [SKPhysicsBody bodyWithCircleOfRadius:10];
    movePoint.physicsBody.dynamic = NO;
    movePoint.zPosition           = 0.5;
    
    movePoint.lineWidth   = 0.01;
    movePoint.fillColor   = [SKColor blackColor];
    movePoint.strokeColor = [SKColor whiteColor];
    movePoint.glowWidth   = 0.0001;
    
    return movePoint;

}

-(void)adjustSizeWithTouches:(NSSet *)touches
{
    NSLog(@"in block adjusting size");
    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    CGPoint previousLocation  = [touch previousLocationInNode:self];
    
    
    float offX        = touchLocation.x - previousLocation.x;
    float offY        = touchLocation.y - previousLocation.y;
    float offsetSizeY = touchLocation.y - self.position.y;
    
    float scaleX     = offX / (self.frame.size.width/2);
    float scaleY     = offY / (self.frame.size.height/2);
    float scaleXBall = offX / (self.frame.size.width/2);
    float scaleYBall = offY / (self.frame.size.height/2);
        
    scaleX *= -1.0;
        
    if (scaleX != 0) {
            
        scaleX     = 1.0 + scaleX;
        scaleXBall = 1.0 + (scaleXBall * 1.0);
            
    } else if (scaleX == 0) {
        
        scaleX     = 1.0;
        scaleXBall = 1.0;
    }
        
    if (scaleY != 0) {
        if (offsetSizeY > 10 || offsetSizeY < -10) {
            scaleY     = 1.0 + scaleY;
            scaleYBall = 1.0 + (scaleYBall * -1.0);
        } else {
            NSLog(@"to small");
            scaleY     = 1.0;
            scaleYBall = 1.0;
        }
            
    } else if (scaleY == 0) {
        scaleY     = 1.0;
        scaleYBall = 1.0;
    }
        
    SKAction *adjust = [SKAction scaleXBy:scaleX y:scaleY duration:0];
    [self runAction:adjust];
    //SKAction *adjustBall = [SKAction scaleXBy:scaleXBall y:scaleYBall duration:0.0];
    //nodeAtTouch.xScale = 1.0;
    
}

-(void)adjustRotationWithTouches:(NSSet *)touches
{
    
    for (UITouch *touch in touches) {
        CGPoint positionInScene = [touch locationInNode:self.parent];
        
        float deltaX = positionInScene.x - self.position.x;
        float deltaY = positionInScene.y - self.position.y;
        
        float angle = atan2f(deltaY, deltaX);
        self.zRotation = angle - SK_DEGREES_TO_RADIANS(90.0f);
    }

    
}

@end
