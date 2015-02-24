//
//  GameScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 2/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameScene.h"
#import "Constants.h"

@implementation GameScene


-(SKNode *)createNodeTree
{
    SKNode *mainNode       = [[SKNode alloc] init];
    SKNode *blockNode      = [[SKNode alloc] init];
    SKNode *ballNode       = [[SKNode alloc] init];
    SKNode *paddleNode     = [[SKNode alloc] init];
    SKNode *contentNode    = [[SKNode alloc] init];
    SKNode *overlayNode    = [[SKNode alloc] init];
    SKNode *backgroundNode = [[SKNode alloc] init];
    
    mainNode.name       = mainNodeName;
    blockNode.name      = blockNodeName;
    ballNode.name       = ballNodeName;
    paddleNode.name     = paddleNodeName;
    overlayNode.name    = overlayNodeName;
    contentNode.name    = contentNodeName;
    backgroundNode.name = backgroundNodeName;
    
    CGPoint origin = CGPointZero;
    mainNode.position       = origin;
    blockNode.position      = origin;
    ballNode.position       = origin;
    paddleNode.position     = origin;
    overlayNode.position    = origin;
    contentNode.position    = origin;
    backgroundNode.position = origin;
    
    overlayNode.zPosition    = 1.0;
    
    [contentNode addChild:blockNode];
    [contentNode addChild:ballNode];
    [contentNode addChild:paddleNode];
    [mainNode    addChild:contentNode];
    [mainNode    addChild:overlayNode];
    [mainNode    addChild:backgroundNode];

    return mainNode;
    
}
@end
