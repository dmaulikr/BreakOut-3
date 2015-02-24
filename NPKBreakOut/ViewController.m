//
//  ViewController.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/12/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "ViewController.h"
#import "StartScene.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    SKView *mainView = [[SKView alloc] initWithFrame:self.view.frame];
    mainView.showsDrawCount = YES;
    mainView.showsNodeCount = YES;
    mainView.showsFPS = YES;
    mainView.ignoresSiblingOrder = YES;
    
    [self.view addSubview:mainView];
    
    
    StartScene *startView = [[StartScene alloc] initWithSize:self.view.frame.size];
    
    [mainView presentScene:startView];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
