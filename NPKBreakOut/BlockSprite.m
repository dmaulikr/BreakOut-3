//
//  BlockSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "BlockSprite.h"
#import "RotateSprite.h"
#import "HitPointSprite.h"
#import "Constants.h"

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)

static NSString * const currentSizeKey  = @"currentSize";
static NSString * const hitPointsKey    = @"hitPoints";
static NSString * const hasPowerUpKey   = @"hasPowerUp";
static NSString * const canBeEditedKey  = @"canBeEdited";
static NSString * const nameKey          = @"name";
static NSString * const positionKey      = @"position";
static NSString * const blockKey         = @"block";



//static double editPointRadius = 7.5;

@interface BlockSprite ()

@property (nonatomic) RotateSprite *rotatePoint;


@end

@implementation BlockSprite


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    
    if (self = [super initWithCoder:aDecoder]) {
        BlockSprite *block = [[BlockSprite alloc]  initWithLocation:[[aDecoder decodeObjectForKey:positionKey] CGPointValue]
                                                          hitPoints:[aDecoder decodeIntForKey:hitPointsKey]
                                                               name:[aDecoder decodeObjectForKey:nameKey]
                                                         hasPowerup:[aDecoder decodeBoolForKey:hasPowerUpKey]
                                                        currentSize: [aDecoder decodeObjectForKey:currentSizeKey]
                                                        canBeEdited:[aDecoder decodeObjectForKey:canBeEditedKey]];
        
        self = block;
        
    }
    return self;
}

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


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //NSLog(@"saving block");
    //NSLog(@"name %@", self.name);
    
    NSValue *position = [NSValue valueWithCGPoint:self.position];
 
    [aCoder encodeObject:self.currentSize forKey:currentSizeKey];
    [aCoder encodeInteger:self.hitPoints forKey:hitPointsKey];
    [aCoder encodeBool:self.hasPowerup forKey:hasPowerUpKey];
    [aCoder encodeBool:self.canBeEdited forKey:canBeEditedKey];
    [aCoder encodeObject:self.name forKey:nameKey];
    [aCoder encodeObject:position forKey:positionKey];
    
    
}

-(void)addHitPoint
{
    if (self.hitPointsCanBeChanged) {
        if (self.hitPoints == 1) {
            self.hitPoints++;
        } else if (self.hitPoints == 2) {
            self.hitPoints++;
        } else if (self.hitPoints == 3) {
            self.hitPoints = 1;
        }
        [self updateSelf];
    }
    
}



-(void)updateSelf
{
    if (self.hitPoints == 3) {
        
        self.color            = [UIColor redColor];
        self.colorBlendFactor = 0.9;
        
    } else if (self.hitPoints == 2) {
        
        self.color            = [UIColor redColor];

        self.colorBlendFactor = 0.4;
        
    } else {
        
        self.colorBlendFactor = 0.0;
        
    }
    
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
    
    /*
    SKLabelNode *hitPointLabel = (SKLabelNode *)[self childNodeWithName:hitPointsLabelName];
    
    if (self.hitPointsCanBeChanged) {
        if (!hitPointLabel) {
            [self createHitPointLabel];
        } else {
            hitPointLabel.text = [NSString stringWithFormat:@"%d",self.hitPoints];
        }
    } else {
        if (hitPointLabel) {
            [hitPointLabel removeFromParent];
        }
    } */
}


-(void)createRotatePoint
{
    RotateSprite *rotatePoint = [[RotateSprite alloc] initWithColor:[UIColor blackColor]
                                                               size:CGSizeMake(20, 20)
                                                               name:rotatePointName];
    rotatePoint.position = CGPointMake(0, 1.5);
    
    [self addChild:rotatePoint];

}


/*
-(void)createHitPointLabel
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    label.text = [NSString stringWithFormat:@"%d", self.hitPoints];
    label.fontSize = 18;
    label.fontColor = [UIColor blackColor];
    label.name = hitPointsLabelName;
    label.position = CGPointMake(0, -5);
    label.zPosition = 3;
    
    [self addChild:label];

}
 */

/*

-(void)createEditPointTopLeft
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
    
    [self addChild:editPointTopLeft];
}
*/


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
    //float scaleXBall = offX / (self.frame.size.width/2);
    //float scaleYBall = offY / (self.frame.size.height/2);
        
    scaleX *= -1.0;
        
    if (scaleX != 0) {
            
        scaleX     = 1.0 + scaleX;
        //scaleXBall = 1.0 + (scaleXBall * 1.0);
            
    } else if (scaleX == 0) {
        
        scaleX     = 1.0;
        //scaleXBall = 1.0;
    }
        
    if (scaleY != 0) {
        if (offsetSizeY > 10 || offsetSizeY < -10) {
            scaleY     = 1.0 + scaleY;
            //scaleYBall = 1.0 + (scaleYBall * -1.0);
        } else {
            NSLog(@"to small");
            scaleY     = 1.0;
            //scaleYBall = 1.0;
        }
            
    } else if (scaleY == 0) {
        scaleY     = 1.0;
        //scaleYBall = 1.0;
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
