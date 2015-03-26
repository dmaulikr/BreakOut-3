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
        self.startScene.dataView = self;
        [self createContents];
    }
    return  self;
}


-(void)createContents
{
    [self createTitle];
    [self createPlayButton];
    [self createDeleteButton];

    
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

-(void)createDeleteButton
{
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete addTarget:self
               action:@selector(deleteButtonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    [delete setTitle:@"Delete" forState:UIControlStateNormal];
    delete.titleLabel.font = [UIFont fontWithName:@"arial" size:32];
    [delete setFrame:CGRectMake(130, 500, 100, 60)];
    [delete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:delete];
}

-(void)deleteButtonPressed
{
    if ([[GameData sharedGameData] deleteSaveFile:self.textField.text]) {
        NSLog(@"deleted");
    } else {
        NSLog(@"cant delete");
    }
    [self.startScene createSceneContents];
    [self removeFromSuperview];
    
}

-(void)playButtonPressed
{
    if ([[GameData sharedGameData] doesSaveFileExist:self.fileName]) {
        NSLog(@"dataView play %@", self.fileName);
        [[GameData sharedGameData] initWithFileName:self.fileName];

        NSLog(@"gamedata savefileName %@", [GameData sharedGameData].saveFileName);
    }
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
            NSLog(@"saved data does exist and the name has changed deleteing and saving");
            
            if (![self.textFieldInput isEqualToString:@""]) {
                //add name validation here
                if ([[GameData sharedGameData] deleteSaveFile:self.fileName]) {
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
