//
//  GameView.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/20/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GameView.h"
#import "StartScene.h"

@implementation GameView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsDrawCount = YES;
        self.showsNodeCount = YES;
        self.showsFPS = YES;
        self.ignoresSiblingOrder = YES;
        StartScene *startView = [[StartScene alloc] initWithSize:self.frame.size];
        
        [self presentScene:startView];
        
    }
    return self;
}



@end
