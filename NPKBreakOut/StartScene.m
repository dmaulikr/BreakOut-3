//
//  StartScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "StartScene.h"
#import "MainScene.h"
#import "EditGameScene.h"
#import "GameData.h"

@implementation StartScene

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor blueColor];

        [self createSceneContents];

        [[GameData sharedGameData] reset];
    }
    
    return self;
}

-(void)createSceneContents
{
    
    [self createTitle];
    [self createPlayButton];
    [self createEditButton];
    
    //[super view];
    
}

-(void)createTitle
{
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    title.text = @"Super BreakOut";
    title.fontSize = 50;
    title.name = @"title";
    title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-200);
    title.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:title.frame.size];
    title.physicsBody.dynamic = NO;

    [self addChild:title];


    SKAction *swivel = [SKAction rotateByAngle:.2 duration:1.0];
    SKAction *swivelForward = [SKAction rotateByAngle:.4 duration:2.0];
    SKAction *swivelBack = [SKAction rotateByAngle:-.4 duration:2.0];
    SKAction *swivelForwardAndBack = [SKAction sequence:@[swivelBack, swivelForward]];
    SKAction *swivelForwardAndBackForever = [SKAction repeatActionForever:swivelForwardAndBack];
    
    
    
    SKAction *shrinkFirst = [SKAction scaleTo:0.8 duration:1.0];
    SKAction *shrink = [SKAction scaleTo:0.9 duration:2.0];
    SKAction *grow = [SKAction scaleTo:1.1 duration:2.0];
    SKAction *shrinkAndGrow = [SKAction sequence:@[grow, shrink]];
    SKAction *shrinkAndGrowForever = [SKAction repeatActionForever:shrinkAndGrow];
    
    SKAction *swivelShrink = [SKAction group:@[swivel, shrinkFirst]];
    SKAction *swivelResizeForever = [SKAction group:@[swivelForwardAndBackForever, shrinkAndGrowForever]];
    
    [title runAction:swivelShrink completion:^{
        [title runAction:swivelResizeForever withKey:@"swivelResizeForever"];
    }];
    
    

}

-(void)createPlayButton
{
    SKLabelNode *playButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    playButton.text = @"Play";
    playButton.fontSize = 32;
    playButton.name = @"play";
    playButton.position = CGPointMake(self.frame.size.width/4, self.frame.size.height * 0.3);
    playButton.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playButton.frame.size];
    playButton.physicsBody.dynamic = NO;
    
    [self  addChild:playButton];
    
}

-(void)createEditButton
{
    SKLabelNode *editButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    editButton.text = @"Edit";
    editButton.fontSize = 32;
    editButton.name = @"edit";
    editButton.position = CGPointMake(self.frame.size.width * 0.75, self.frame.size.height * 0.3);
    editButton.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:editButton.frame.size];
    editButton.physicsBody.dynamic = NO;
    
    [self addChild:editButton];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:[[touches anyObject] locationInNode:self]];
    if (body && [body.node.name isEqualToString:@"title"]) {
        
    } else if (body && [body.node.name isEqualToString:@"play"]) {
        NSLog(@"play");
        NSArray *array = [[NSArray alloc] init];
        MainScene *mainScene = [[MainScene alloc] initWithSize:self.frame.size sprites:array];
        [self.view presentScene:mainScene];
    } else if (body && [body.node.name isEqualToString:@"edit"]) {
        NSLog(@"Edit");
        EditGameScene *editScene = [[EditGameScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:editScene];
    }
}

@end
