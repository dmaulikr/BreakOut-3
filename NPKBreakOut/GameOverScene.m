//
//  GameOverScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/17/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameOverScene.h"
#import "MainScene.h"
#import "StartScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon
{
    self = [super initWithSize:size];
    if (self) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];

        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        gameOverLabel.fontSize = 42;
        gameOverLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        if (isWon) {
            gameOverLabel.text = @"Game Won";
        } else {
            gameOverLabel.text = @"Game Over";
        }
        [self addChild:gameOverLabel];
    }
    
    return self;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    StartScene * startScene = [[StartScene alloc] initWithSize:self.size];
    [self.view presentScene:startScene];
}

@end
