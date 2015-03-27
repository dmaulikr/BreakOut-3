//
//  ViewController.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/12/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "ViewController.h"
#import "GameView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GameView *mainView = [[GameView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:mainView];
    

    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
