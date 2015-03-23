//
//  DataView.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "DataView.h"

@interface DataView ()

@property (nonatomic) NSString *fileName;


@end

@implementation DataView

-(instancetype)initWithFrame:(CGRect)frame fileName:(NSString *)fileName
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self.fileName = fileName;
        [self createContents];
    }
    return  self;
}


-(void)createContents
{
    UILabel *title = [[UILabel alloc] init];
    title.text = self.fileName;
    title.frame = CGRectMake(50, 50, 20, 20);
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor blackColor];
    [self.superview addSubview:title];
    
    
}

@end
