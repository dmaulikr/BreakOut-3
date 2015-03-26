//
//  DataTableView.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "DataTableView.h"
#import "Constants.h"
#import "GameData.h"
#import "DataView.h"

static NSString * const reusableCellName = @"aCell";


@interface DataTableView ()

@property (nonatomic) NSMutableArray *saveFiles;

@end


@implementation DataTableView


-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        
        [self createBackButton];
        
        NSString *url = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:saveFileDirectory];
        
        NSArray *filesUrl = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url error:Nil];
        if (filesUrl) {
            NSLog(@"table files Loaded");
            self.saveFiles = (NSMutableArray *)filesUrl;
        } else {
            NSLog(@"table files couldn't load ");
        }
    }
    return  self;
}

-(void)createBackButton
{
    /*
    NSLog(@"create back button");
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self
                   action:@selector(backButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(-20, 0, 50, 50)];
    backButton.titleLabel.textColor = [UIColor blackColor];
    //backButton.frame = CGRectMake(30, 30, 30, 30);

    [self.superview addSubview:backButton];*/
    
}

-(IBAction)backButtonTapped:(id)sender
{
    NSLog(@"tapped");
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.saveFiles.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:reusableCellName];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellName];
    }
    
    [cell.textLabel setText:[self.saveFiles objectAtIndex:[indexPath row]]];
    
    return  cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellLabel = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    //[[GameData sharedGameData] initWithFileName:cellLabel];
    
    DataView *dataView = [[DataView alloc] initWithFrame:self.frame fileName:cellLabel];
    dataView.layer.cornerRadius = 5;
    dataView.layer.masksToBounds = YES;
    [self.superview addSubview:dataView];

    if ([self.superview.subviews containsObject:self]) {
        [self removeFromSuperview];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


@end
