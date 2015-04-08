//
//  GameScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 2/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameScene.h"
#import "Constants.h"
#import "GameSaveFile.h"
#import "GameData.h"

@implementation GameScene


-(SKNode *)createNodeTree
{
    SKNode *mainNode       = [[SKNode alloc] init];
    SKNode *blockNode      = [[SKNode alloc] init];
    SKNode *ballNode       = [[SKNode alloc] init];
    SKNode *paddleNode     = [[SKNode alloc] init];
    SKNode *powerUpNode    = [[SKNode alloc] init];
    SKNode *contentNode    = [[SKNode alloc] init];
    SKNode *overlayNode    = [[SKNode alloc] init];
    SKNode *backgroundNode = [[SKNode alloc] init];
    SKNode *optionsNode    = [[SKNode alloc] init];
    
    mainNode.name       = mainNodeName;
    blockNode.name      = blockNodeName;
    ballNode.name       = ballNodeName;
    paddleNode.name     = paddleNodeName;
    powerUpNode.name    = powerUpNodeName;
    overlayNode.name    = overlayNodeName;
    contentNode.name    = contentNodeName;
    backgroundNode.name = backgroundNodeName;
    optionsNode.name    = optionsNodeName;
    
    CGPoint origin = CGPointZero;
    mainNode.position       = origin;
    blockNode.position      = origin;
    ballNode.position       = origin;
    paddleNode.position     = origin;
    powerUpNode.position    = origin;
    overlayNode.position    = origin;
    contentNode.position    = origin;
    backgroundNode.position = origin;
    optionsNode.position    = origin;
    
    overlayNode.zPosition    = 1.0;
    
    [contentNode addChild:blockNode];
    [contentNode addChild:ballNode];
    [contentNode addChild:paddleNode];
    [contentNode addChild:powerUpNode];
    [mainNode    addChild:contentNode];
    [mainNode    addChild:overlayNode];
    [mainNode    addChild:backgroundNode];
    [mainNode    addChild:optionsNode];

    return mainNode;
    
}

-(void)setupSaveFile
{
    //NSLog(@"savefile name %@", file.saveFileName);
    
    if ([[GameData sharedGameData].saveFile.saveFileName isEqualToString:@""]) {
        GameSaveFile *newSave = [[GameSaveFile alloc] init];
        NSLog(@"scene has no saveFileName");
        NSDate *now = [NSDate date];
        newSave.saveFileName = [now description];
        [GameData sharedGameData].saveFile = newSave;
        [[GameData sharedGameData] archiveSaveFile];

    } else {
        NSLog(@"starting, scene Has savefile");
    }
}

@end
