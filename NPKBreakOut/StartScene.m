//
//  StartScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "StartScene.h"
#import "MainScene.h"
#import "EditGameScene.h"
#import "GameData.h"
#import "Constants.h"
#import "DataTableView.h"
#import "DataView.h"


static NSString * const playLabelName = @"play";
static NSString * const editLabelName   = @"edit";
static NSString * const loadLabelName = @"load";

@interface StartScene  ()

@property (nonatomic) int playLabelHeight;

@end

@implementation StartScene

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blueColor];
        self.playLabelHeight = self.frame.size.height * 0.15;
        
        [self createSceneContents];

    }
    
    return self;
}

-(void)createSceneContents
{
    
    [self createTitle];
    [self createPlayButton];
    [self createEditButton];
    [self createLoadButton];
    
    //[super view];
    
}

-(void)createTitle
{
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    title.text = @"Super BreakOut";
    title.fontSize = 50;
    title.name = @"title";
    title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-200);
    title.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:title.frame.size];
    title.physicsBody.dynamic = NO;

    [self addChild:title];


    SKAction *swivel = [SKAction rotateByAngle:.2 duration:1.0];
    SKAction *swivelForward = [SKAction rotateByAngle:.4 duration:2.0];
    SKAction *swivelBack = [SKAction rotateByAngle:-.4 duration:2.0];
    SKAction *swivelForwardAndBack = [SKAction sequence:@[swivelBack, swivelForward]];
    SKAction *swivelForwardAndBackForever = [SKAction repeatActionForever:swivelForwardAndBack];
    
    
    
    SKAction *shrinkFirst = [SKAction scaleTo:0.8 duration:1.0];
    SKAction *shrink = [SKAction scaleTo:0.9 duration:2.0];
    SKAction *grow = [SKAction scaleTo:1.1 duration:2.0];
    SKAction *shrinkAndGrow = [SKAction sequence:@[grow, shrink]];
    SKAction *shrinkAndGrowForever = [SKAction repeatActionForever:shrinkAndGrow];
    
    SKAction *swivelShrink = [SKAction group:@[swivel, shrinkFirst]];
    SKAction *swivelResizeForever = [SKAction group:@[swivelForwardAndBackForever, shrinkAndGrowForever]];
    
    [title runAction:swivelShrink completion:^{
        [title runAction:swivelResizeForever withKey:@"swivelResizeForever"];
    }];
    
    

}

-(void)createPlayButton
{
    SKLabelNode *playButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    playButton.text = @"Play";
    playButton.fontSize = 32;
    playButton.name = playLabelName;
    playButton.position = CGPointMake(self.frame.size.width/4, self.playLabelHeight);
    playButton.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playButton.frame.size];
    playButton.physicsBody.dynamic = NO;
    
    [self  addChild:playButton];
    
}

-(void)createEditButton
{
    SKLabelNode *editButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    editButton.text = @"Edit";
    editButton.fontSize = 32;
    editButton.name = editLabelName;
    editButton.position = CGPointMake(self.frame.size.width * 0.75, self.playLabelHeight);
    editButton.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:editButton.frame.size];
    editButton.physicsBody.dynamic = NO;
    
    [self addChild:editButton];
}


-(void)createLoadButton
{
    SKLabelNode *playButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    playButton.text = @"Load";
    playButton.fontSize = 32;
    playButton.name = loadLabelName;
    playButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.2);
    playButton.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playButton.frame.size];
    playButton.physicsBody.dynamic = NO;
    
    [self  addChild:playButton];
    
}

-(void)createDeleteButton
{
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    if ([node.name isEqualToString:playLabelName]) {
        
        if ([[self.view subviews] containsObject:self.tableView]) {
            [self.tableView removeFromSuperview];
        }
        MainScene *mainScene = [[MainScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:mainScene];
        
        
    } else if ([node.name isEqualToString:editLabelName]) {
        EditGameScene *editScene = [[EditGameScene alloc] initWithSize:self.frame.size];
        [self.view presentScene:editScene];
    } else if ([node.name isEqualToString:loadLabelName]) {
        [self createTable];
    } else if (node.name == Nil) {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                [view removeFromSuperview];
            }
            
        }

    }
}

-(void)createTable
{

    float scaleFactor = 0.85;
    float tableWidth = self.frame.size.width*scaleFactor;
    
    float tableHeight = self.frame.size.height - self.playLabelHeight - 55;
    
    float tablePositionX = (self.frame.size.width * (1 - scaleFactor)/2);
    float tablePositionY = 20;

    DataTableView *table = [[DataTableView alloc] initWithFrame:CGRectMake(tablePositionX, tablePositionY, tableWidth, tableHeight) style:UITableViewStylePlain];
    table.delegate = table;
    table.dataSource = table;
    table.layer.cornerRadius = 5;
    table.layer.masksToBounds = YES;
    self.tableView = table;

    [self.view addSubview:self.tableView];
    

    
}




@end
