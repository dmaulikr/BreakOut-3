//
//  DataView.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "DataView.h"
#import "GameData.h"
#import "StartScene.h"

@interface DataView ()

@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *textFieldInput;
@property (nonatomic) UITextField *textField;
@property (nonatomic) StartScene *startScene;


@end

@implementation DataView

-(instancetype)initWithFrame:(CGRect)frame fileName:(NSString *)fileName
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        self.fileName = fileName;
        self.textFieldInput = @"";
        self.startScene = [GameData sharedGameData].startScene;
        [self createContents];
    }
    return  self;
}


-(void)createContents
{
    [self createTitle];
    [self createPlayButton];
    

    
}

-(void)createPlayButton
{
    
    UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
    [play addTarget:self
             action:@selector(playButtonPressed)
   forControlEvents:UIControlEventTouchUpInside];
    [play setTitle:@"Play" forState:UIControlStateNormal];
    [play setFrame:CGRectMake(30, 550,100, 60)];
    play.titleLabel.font = [UIFont fontWithName:@"arial" size:32];
    [play setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:play];
}

-(void)playButtonPressed
{
    [[GameData sharedGameData] initWithFileName:self.fileName];
    
    [self.startScene startMainScene];
    [self removeFromSuperview];
    
}

-(void)createTitle
{
    UITextField *title = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 40)];
    title.delegate = self;

    title.text = self.fileName;
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor blackColor];
    title.textAlignment = NSTextAlignmentCenter;

    
    self.textField = title;
    [self addSubview:title];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    self.textFieldInput = textField.text;
    if ([[GameData sharedGameData] doesSaveFileExist:self.fileName]) {
        
        if (![self.fileName isEqualToString:self.textFieldInput]) {
            NSLog(@"saved data does exist and then ame has changed deleteing and saving");
            
            if (![self.textFieldInput isEqualToString:@""]) {
                //add name validation here
                if ([[GameData sharedGameData] deleteSaveFile:self.fileName]) {
                    NSLog(@"data deleted");
                    [[GameData sharedGameData] saveWithFileName:self.textFieldInput];
                    self.fileName = self.textFieldInput;
                } else {
                    NSLog(@"error cant delete data %@", self.fileName);
                }
            } else {
                NSLog(@"text field was empty no saving");
                self.textField.text = self.fileName;
            }

        } else {
            NSLog(@"name hasnt changed no saving");
            
        }
    }
    
}


@end
