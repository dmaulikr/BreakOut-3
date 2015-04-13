//
//  HitPointSprite.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 4/9/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "HitPointSprite.h"
#import "Constants.h"

@interface HitPointSprite ()

@property (nonatomic) SKLabelNode *hpLabel;

@end

@implementation HitPointSprite


-(instancetype)init
{
    if (self = [super initWithTexture:[SKTexture textureWithImageNamed:@"hitPointsButton.png"] color:nil size:CGSizeMake(50, 50)]) {

        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
        self.physicsBody.dynamic = NO;
        self.name = hitPointsButtonName;
        self.isPressed = NO;

        self.hpLabel = [self createHpLabel];
        [self addChild:self.hpLabel];

    }
    return self;
}

-(SKLabelNode *)createHpLabel
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    label.fontSize  = 20;
    label.fontColor = [UIColor blackColor];
    label.text      = @"HP";
    label.zPosition = 10;
    label.position = CGPointMake(0, -8);
    label.name = hitPointsLabelName;
    
    return label;
}

-(void)changeStatus
{
    if (self.isPressed) {
        [self stopColorChange];
    } else {
        [self startColorChange];
    }
    
}

-(void)startColorChange
{
    self.isPressed = YES;
    SKAction *changeColorHP1 = [SKAction colorizeWithColorBlendFactor:0.0 duration:0];
    SKAction *changeLabelHP1 = [SKAction runBlock:^{
        [self.hpLabel setText:@"1"];
    }];
    SKAction *groupHP1 = [SKAction group:@[changeColorHP1, changeLabelHP1]];
    
    SKAction *changeColorHP2 = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.4 duration:0];
    SKAction *changeLabelHP2 = [SKAction runBlock:^{
        [self.hpLabel setText:@"2"];
    }];
    SKAction *groupHP2 = [SKAction group:@[changeColorHP2, changeLabelHP2]];
    
    SKAction *changeColorHP3 = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.9 duration:0];
    SKAction *changeLabelHP3 = [SKAction runBlock:^{
        [self.hpLabel setText:@"3"];
    }];
    SKAction *groupHP3 = [SKAction group:@[changeColorHP3, changeLabelHP3]];
    
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *fullColorChange = [SKAction sequence:@[groupHP1, wait, groupHP2, wait, groupHP3, wait]];
    SKAction *repeatingChange = [SKAction repeatActionForever:fullColorChange];
    [self runAction:repeatingChange];
    
}

-(void)stopColorChange
{
    [self removeAllActions];
    [self removeAllChildren];
    self.colorBlendFactor = 0.0;
    self.hpLabel = [self createHpLabel];
    [self addChild:self.hpLabel];
    self.isPressed = NO;
    
}
@end
