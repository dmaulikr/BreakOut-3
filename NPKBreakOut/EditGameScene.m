//
//  EditGameScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//
// rotate icon http://cdn.flaticon.com/png/256/22.png

#import "EditGameScene.h"
#import "BlockSprite.h"
#import "BallSprite.h"
#import "PaddleSprite.h"
#import "PowerUpSprite.h"
#import "MainScene.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameData.h"
#import "GameSaveFile.h"
#import "RotateSprite.h"
#import "HitPointSprite.h"
#import "GridSprite.h"
#import "PowerSprite.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)


static NSString * const overlayBlockName = @"first";
static NSString * const overlayBallName = @"second";
static NSString * const overlayPaddleName = @"third";
static NSString * const overlayPowerUpBigName = @"fourth";
static NSString * const overlayPowerUpDoubleName = @"fifth";


static NSString * const editPointTopLeftName =  @"editPointTopLeft";
static NSString * const playButtonName = @"play";
static NSString * const saveButtonName = @"save";


@interface EditGameScene ()

@property (nonatomic) SKNode *nodePressedAtTouchBegins;
@property (nonatomic) BlockSprite* rotatingBlock;
@property (nonatomic) BOOL shouldAutoAdjustMovingBlocks;

@property (nonatomic) float bottomOptionsBuffer;
@property (nonatomic) float rightOptionsBuffer;
@property (nonatomic) float bottomOptionsHeightLimit;
@property (nonatomic) float rightOptionsWidthLimit;
@property (nonatomic) float blockHeight;
@property (nonatomic) float bottomOptionsHeight;

@property (nonatomic) BOOL isAdjustingSize;
@property (nonatomic) BOOL shouldBlocksRotate;
@property (nonatomic) BOOL isObjectRotating;
@property (nonatomic) BOOL isAdjustingBackground;
@property (nonatomic) BOOL shouldMoveBottomOptions;
@property (nonatomic) BOOL shouldMoveRightOptions;
@property (nonatomic) BOOL shouldMoveLeftOptions;
@property (nonatomic) BOOL shouldMoveUpOptions;

@end

@implementation EditGameScene

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        [self addChild:[super createNodeTree]];
        [super setupSaveFile];
        
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        self.physicsWorld.gravity         = CGVectorMake(0.0, 0.0);
        self.physicsBody                  = borderBody;
        self.physicsBody.friction         = 0.0;
        self.physicsWorld.contactDelegate = self;
        self.name                         = @"world";
        //self.anchorPoint                 = CGPointZero;
        self.shouldAutoAdjustMovingBlocks = NO;

        self.blockHeight              = [[SKSpriteNode alloc] initWithImageNamed:@"block.png"].frame.size.height;
        self.bottomOptionsHeight      = [[SKSpriteNode alloc] initWithImageNamed:@"bottomOptions.png"].frame.size.height;
        self.bottomOptionsHeightLimit = 90;
        self.rightOptionsWidthLimit   = self.frame.size.width - 90.0;
        self.bottomOptionsBuffer      = 100;
        self.rightOptionsBuffer       = 100;

        
        [self createBackground];
        [self createContents];
        [self createBottomOptions];
        [self createRightOptions];
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    UITapGestureRecognizer       *tapRecognizer       = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(handleDoubleTap:)];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]  initWithTarget:self
                                                                                                       action:@selector(handleLongPress:)];
    tapRecognizer.delegate                   = self;
    tapRecognizer.numberOfTapsRequired       = 2;
    longPressRecognizer.minimumPressDuration = 0.5;
    
    
    //[[self view] addGestureRecognizer:tapRecognizer];
    [[self view] addGestureRecognizer:longPressRecognizer];
}

-(void)createContents
{
    if ([GameData sharedGameData].saveFile.blocks.count > 0)  [self createBlocksFromData];
    if ([GameData sharedGameData].saveFile.balls.count > 0)   [self createBallsFromData];
    if ([GameData sharedGameData].saveFile.paddles.count > 0) [self createPaddlesFromData];
    //self.physicsWorld.speed = 0;
    
}

-(void)createBlocksFromData
{
    for (BlockSprite *block in [GameData sharedGameData].saveFile.blocks) {
        block.physicsBody.dynamic = YES;
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
    }
}

-(void)createBallsFromData
{
    for (BallSprite *ball in [GameData sharedGameData].saveFile.balls) {
        ball.physicsBody.dynamic = NO;
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    }
}


-(void)createPaddlesFromData
{
    for (PaddleSprite *paddle in [GameData sharedGameData].saveFile.paddles) {
        
        paddle.physicsBody.categoryBitMask    = paddleCategory;
        paddle.physicsBody.contactTestBitMask = powerUpCategory;
        
        [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    }
    
}


-(void)createBackground
{
    SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
    background.position       = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    background.name           = backgroundName;
    
    [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
}

-(void)createRightOptions
{
    SKSpriteNode *rightOptions = [SKSpriteNode spriteNodeWithImageNamed:@"rightOptions"];
    rightOptions.anchorPoint = CGPointZero;
    rightOptions.position = CGPointMake(self.frame.size.width, 0);
    rightOptions.name = rightOptionsName;
    //NSLog(@"screen %f x %f", self.frame.size.width, rightOptions.position.x);
    
    [[self childNodeWithName: optionsNodeNameSearch] addChild:rightOptions];
    
    SKLabelNode *play        = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    play.text                = @"play";
    play.fontSize            = 30;
    play.name                = playButtonName;
    play.physicsBody         = [SKPhysicsBody bodyWithRectangleOfSize:play.frame.size];
    play.position            = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height/10);
    play.physicsBody.dynamic = NO;
    [rightOptions addChild:play];
    
    SKLabelNode *save  = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    save.text = @"save";
    save.fontSize = 30;
    save.name   = saveButtonName;
    save.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:save.frame.size];
    save.position = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height/5.5);
    save.physicsBody.dynamic = NO;
    [rightOptions addChild:save];
    
    RotateSprite *rotateButton = [[RotateSprite alloc] initWithColor:nil size:CGSizeMake(50, 50) name:rotateButtonName];
    rotateButton.position = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height - rotateButton.frame.size.height - 30);
    [rightOptions addChild:rotateButton];
    
    HitPointSprite *hitPointsButton = [[HitPointSprite alloc] init];
    hitPointsButton.position = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height - 170);
    [rightOptions addChild:hitPointsButton];
    
    GridSprite *gridButton = [[GridSprite alloc] init];
    gridButton.position = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height- 230);
    [rightOptions addChild:gridButton];
    
    PowerSprite *power = [[PowerSprite alloc] init];
    power.position = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height - 330);
    [rightOptions addChild:power];
    
    
    
}

-(void)createBottomOptions
{
    
    SKSpriteNode *bottomOptions = [SKSpriteNode spriteNodeWithImageNamed:@"bottomOptions"];
    
    bottomOptions.anchorPoint = CGPointMake(0,0);
    bottomOptions.position = CGPointMake(0,bottomOptions.frame.size.height * -1);
    bottomOptions.name = bottomOptionsName;
    
    
    [[self childNodeWithName:optionsNodeNameSearch] addChild:bottomOptions];
    [self createBottomOptionsOverlayObjects];
    

}

-(void)createBottomOptionsOverlayObjects
{
    SKSpriteNode *bottomOptions = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"//%@", bottomOptionsName]];
    
    [bottomOptions removeAllChildren];
    BlockSprite *block = [[BlockSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/4, 100)
                                                     hitPoints:1
                                                          name:overlayBlockName
                                                    hasPowerupType:@""
                                                   currentSize:@"normal"
                                                   canBeEdited:NO];
    block.zPosition = 100;
    
    BallSprite *ball = [[BallSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/2, 100)
                                                currentSize:@"normal"
                                                     status:@"normal"
                                                       name:overlayBallName];
    ball.zPosition = 100;
    ball.physicsBody.dynamic = NO;
    
    PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                            position:CGPointMake(self.frame.size.width * 3/4, 100)
                                                              status:@"normal"
                                                                name:overlayPaddleName];
    paddle.zPosition = 100;
    
    [bottomOptions addChild:block];
    [bottomOptions addChild:ball];
    [bottomOptions addChild:paddle];
}

-(void)createBottomOptionsPowerUps
{
    SKSpriteNode *bottomOptions = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"//%@", bottomOptionsName]];
    [bottomOptions removeAllChildren];
    
    PowerUpSprite *powerUpRed = [[PowerUpSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/3, 100)
                                                                type:powerUpBigBall
                                                                name:overlayPowerUpBigName
                                                          shouldMove:NO];
    
    PowerUpSprite *powerUpBlue = [[PowerUpSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/2, 100)
                                                                type:powerUpDoubleBall
                                                                name:overlayPowerUpDoubleName
                                                          shouldMove:NO];
    [bottomOptions addChild:powerUpRed];
    [bottomOptions addChild:powerUpBlue];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    self.nodePressedAtTouchBegins = node;

    
    NSLog(@"touch begins pressed %@", node.name);
    
    if ([node.name isEqualToString:blockNodeName]) {
        self.nodePressedAtTouchBegins = nil;
    }


    if ([node.name isEqualToString:playButtonName]) {
        if (![self checkSceneForMissingSprites]) {
            [self switchToMainScene];
        }
    }
    
    if ([node.name isEqualToString:saveButtonName]) {
        [self switchToStartScene];
        
    }
    
    if ([node.name isEqualToString:rotateButtonName]) {
        
        RotateSprite *button = (RotateSprite*)node;

        [button changeStatus];
        if (button.isPressed) {
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite *)node;
                block.isRotatable = YES;
                [block updateSelf];
            }];
        } else {
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite*)node;
                block.isRotatable = NO;
                [block updateSelf];
            }];

        }
        
    }

    if ([node.name isEqualToString:hitPointsButtonName] || [node.name isEqualToString:hitPointsLabelName]) {
        HitPointSprite *button;
        if ([node.name isEqualToString:hitPointsButtonName]) {
            button = (HitPointSprite *)node;
        } else if ([[node parent].name isEqualToString:hitPointsButtonName]){
            button = (HitPointSprite *)[node parent];
        }
        
        [button changeStatus];
        
        
        if (button.isPressed) {
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite *)node;
                block.hitPointsCanBeChanged = YES;
                [block updateSelf];
            }];
        } else {
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite *)node;
                block.hitPointsCanBeChanged = NO;
                [block updateSelf];
            }];
            
        }
    }
    
    if ([node.name containsString:blockName]) {
        BlockSprite *block = (BlockSprite *)node;

        if (block.hitPointsCanBeChanged) {
            [block addHitPoint];
            self.nodePressedAtTouchBegins = nil;
        }
    }
    
    if ([node.name isEqualToString:gridButtonName]) {
        GridSprite *button = (GridSprite *)node;
        [button changeStatus];
        if (button.isPressed) {
            self.shouldAutoAdjustMovingBlocks = YES;
        } else {
            self.shouldAutoAdjustMovingBlocks = NO;
        }
    }
    
    if ([node.name isEqualToString:powerButtonName]) {
        PowerSprite *button = (PowerSprite *)node;
        [button changeStatus];
        if (button.isPressed) {
            [self createBottomOptionsPowerUps];
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite *)node;
                block.showPowerUp = YES;
                [block updateSelf];
            }];
        } else {
            [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                BlockSprite *block = (BlockSprite *)node;
                block.showPowerUp = NO;
                [block updateSelf];
            }];
            [self createBottomOptionsOverlayObjects];
        }
    }
    
    
}




-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    SKNode  *nodeAtTouch      = [self.physicsWorld bodyAtPoint:touchLocation].node;
 
    //NSLog(@"node named %@", self.nodePressedAtTouchBegins.name);
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayBlockName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        BlockSprite *block            = [[BlockSprite alloc] initWithLocation:touchLocation
                                                                    hitPoints:1
                                                                         name:[self nameBlock]
                                                                   hasPowerupType:@""
                                                                  currentSize:@"normal"
                                                                  canBeEdited:YES];
        self.nodePressedAtTouchBegins = block;
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
        [[GameData sharedGameData].saveFile.blocks addObject:block];
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayPowerUpBigName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        PowerUpSprite *powerUp = [[PowerUpSprite alloc]  initWithLocation:touchLocation
                                                                     type:powerUpBigBall
                                                                     name:powerUpName
                                                               shouldMove:NO];
        self.nodePressedAtTouchBegins = powerUp;
        [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUp];
        [[GameData sharedGameData].saveFile.powerUps addObject:powerUp];
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayPowerUpDoubleName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        PowerUpSprite *powerUp = [[PowerUpSprite alloc] initWithLocation:touchLocation
                                                                    type:powerUpDoubleBall
                                                                    name:powerUpName
                                                              shouldMove:NO];
        self.nodePressedAtTouchBegins = powerUp;
        [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUp];
        [[GameData sharedGameData].saveFile.powerUps addObject:powerUp];
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayBallName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        BallSprite *ball = [[BallSprite alloc] initWithLocation:touchLocation
                                                    currentSize:@"normal"
                                                         status:@"normal"
                                                           name:[self nameBall]];
        ball.physicsBody.dynamic = NO;
        self.nodePressedAtTouchBegins = ball;
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
        [[GameData sharedGameData].saveFile.balls addObject:ball];
        
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayPaddleName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                                position:touchLocation
                                                                  status:@"normal"
                                                                    name:[self namePaddle]];
        self.nodePressedAtTouchBegins = paddle;
        [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
        [[GameData sharedGameData].saveFile.paddles addObject:paddle];
    
    }
    if ([self.nodePressedAtTouchBegins.name isEqualToString:powerUpName]) {
        self.nodePressedAtTouchBegins.position = touchLocation;
    }

    if ([self.nodePressedAtTouchBegins.name containsString:ballName]
        && ![self.nodePressedAtTouchBegins.name isEqualToString:ballNodeName]) {
        self.nodePressedAtTouchBegins.position = touchLocation;
    }
    
    if ([self.nodePressedAtTouchBegins.name containsString:paddleName]
        && ![self.nodePressedAtTouchBegins.name isEqualToString:paddleNodeName]) {
        self.nodePressedAtTouchBegins.position = touchLocation;
    }
    
    
    if ([self.nodePressedAtTouchBegins.name containsString:blockName]
        && ![self.nodePressedAtTouchBegins.name isEqualToString:blockNodeName]) {
        
        if (self.shouldAutoAdjustMovingBlocks) {
            [self moveBlockWithTouchLocation:touchLocation];
        } else {
            self.nodePressedAtTouchBegins.position = touchLocation;
        }
    
    }else if ([self.nodePressedAtTouchBegins.name isEqualToString:rotatePointName]) {
        
        if ([self.nodePressedAtTouchBegins.parent.name containsString:blockName]) {
            BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
            [block adjustRotationWithTouches:touches];
        }
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:editPointTopLeftName]) {
        
        BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
        [block adjustSizeWithTouches:touches];
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:backgroundName] ||
            [self.nodePressedAtTouchBegins.name isEqualToString:bottomOptionsName] ||
             [self.nodePressedAtTouchBegins.name isEqualToString:rightOptionsName]){
        [self adjustOptionMenusWithTouches:touches];
    }
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"ended");
    if (self.isAdjustingBackground) {
        [self adjustOptionMenusToRest];
    }
    [[GameData sharedGameData]  archiveSaveFile];
    
    if ([self.nodePressedAtTouchBegins.name containsString:blockName]) {
        //NSLog(@"a node was created/moved");
    }

    self.nodePressedAtTouchBegins = 0;
    self.isObjectRotating         = NO;
    self.isAdjustingSize          = NO;
    self.isAdjustingBackground    = NO;
    self.shouldMoveBottomOptions  = NO;
    self.shouldMoveRightOptions   = NO;
    self.shouldMoveLeftOptions    = NO;
    self.shouldMoveUpOptions      = NO;

    
}


-(void)adjustOptionMenusToRest
{
    //NSLog(@"rest");
    SKNode *bottomOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:bottomOptionsName];
    SKNode *rightOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:rightOptionsName];
    
    //BOOL isBottomOptionsHidden;
    //BOOL isRightOptionsHIdden;
    
    float bottomOptionsY  = bottomOptions.position.y + bottomOptions.frame.size.height;
    float rightOptionsX   = rightOptions.position.x;
    
    float bottomOptionsHeight = bottomOptions.frame.size.height;
    //float rightOptionsWidth = rightOptions.frame.size.width;
    
    int screenWidth  = self.frame.size.width;
    //int screenHeight = self.frame.size.height;
    

    SKAction *slideBottomOptionsUp           = [SKAction moveTo: CGPointMake(0, (self.bottomOptionsHeightLimit - bottomOptionsHeight)) duration:0.5];
    SKAction *slideBottomOptionsDown = [SKAction moveTo:CGPointMake(0.0, -bottomOptionsHeight) duration:0.5];
    SKAction *slideRightOptionsLeft = [SKAction moveTo:CGPointMake(self.rightOptionsWidthLimit, 0.0) duration:0.5];
    SKAction *SlideRightOptionsRight = [SKAction moveTo:CGPointMake(screenWidth, 0) duration:0.5];
    

        
        if (bottomOptionsY <= self.bottomOptionsHeightLimit/2) {
            [bottomOptions runAction:slideBottomOptionsDown];
            //NSLog(@"lower ");
        } else if (bottomOptionsY < (self.bottomOptionsHeightLimit + 60) && bottomOptionsY > (self.bottomOptionsHeightLimit/2)) {
            [bottomOptions runAction:slideBottomOptionsUp];
           // NSLog(@"upper");
        }
        
    
    
    //NSLog(@"x %f  buffer %f", rightOptionsX, self.rightOptionsWidthLimit + 45);
        //NSLog(@"auto move right");
        if (rightOptionsX >=  self.rightOptionsWidthLimit + 45) {
           // NSLog(@"right move to 0");
            [rightOptions runAction:SlideRightOptionsRight];
        
        } else if (rightOptionsX < self.rightOptionsWidthLimit + 45) {
           // NSLog(@"right move onto screen");
            [rightOptions runAction:slideRightOptionsLeft];
        }

    
    

    
}

-(void)adjustOptionMenusWithTouches:(NSSet *) touches
{
    SKNode *bottomOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:bottomOptionsName];
    SKNode *rightOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:rightOptionsName];

    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    CGPoint previousLocation  = [touch previousLocationInNode:self];
    
    float bottomOptionsY      = bottomOptions.position.y + bottomOptions.frame.size.height;
    float rightOptionsX       = rightOptions.position.x;
    //float bottomOptionsHeight = bottomOptions.frame.size.height;
    //float rightOptionsWidth   = rightOptions.frame.size.width;
    
    
    int screenWidth  = self.frame.size.width;
    //int screenHeight = self.frame.size.height;
    
    
    float touchDistanceToBottom = touchLocation.y;
    float touchDistanecToRight  = screenWidth - touchLocation.x;
    
    float yAdjustment = touchLocation.y - previousLocation.y;
    float xAdjustment = touchLocation.x - previousLocation.x;
    
    SKAction *moveBackgroundBottom = [SKAction moveByX:0 y:yAdjustment duration:0];
    SKAction *moveBackgroundRight  = [SKAction moveByX:xAdjustment y:0 duration:0];


 
    if (!self.isAdjustingBackground) {
        NSLog(@"non adjust");
        // this runs on the first time here
        // if the touch is within a boundary to move it turns adjusting on and figures out what should move
        if (touchLocation.y < bottomOptionsY + self.bottomOptionsBuffer) {
            
            self.shouldMoveBottomOptions = YES;
            self.isAdjustingBackground = YES;
           // NSLog(@"move botom");
            
        }
        
       //NSLog(@"touch location %f buffer position %f", touchLocation.x, rightOptionsX - self.rightOptionsBuffer);
        
       if (touchLocation.x > rightOptionsX - self.rightOptionsBuffer) {
            
            self.shouldMoveRightOptions = YES;
            self.isAdjustingBackground = YES;
           // NSLog(@"move right ");
            
        }
        
        //this prevents two from moving at the same time
        if (touchDistanceToBottom < touchDistanecToRight)      self.shouldMoveRightOptions = NO;
        else if (touchDistanecToRight < touchDistanceToBottom) self.shouldMoveBottomOptions = NO;
        
        

    } else {
        //this runs if the tap was within range of boundary to move
        //makes sure that the background dosnt move in the wrong direction

        
        if (bottomOptionsY <= 0 && yAdjustment < 0 && self.shouldMoveBottomOptions) {
            
            self.shouldMoveBottomOptions = NO;
        }
        // if bottom is at 0 and should move and movement is down dont let it move

        if (bottomOptionsY >= self.bottomOptionsHeightLimit && yAdjustment > 0 && self.shouldMoveBottomOptions) {

            self.shouldMoveBottomOptions = NO;
        }
        
        // if bottom is at top and should move and movement is up dont let it move
        
        if (rightOptionsX >= screenWidth && xAdjustment > 0 && self.shouldMoveRightOptions) {
            //NSLog(@"no 1");
            self.shouldMoveRightOptions = NO;

        }
        // if right is at 0 and should move and movement is right dont let it move
        
        if (rightOptionsX <= (self.rightOptionsWidthLimit) && xAdjustment < 0 && self.shouldMoveRightOptions) {
            //NSLog(@"no 2");
            self.shouldMoveRightOptions = NO;
        }

        // if right is at width and should move and movement is left dont let it move


        if (self.shouldMoveBottomOptions) {
            [bottomOptions runAction:moveBackgroundBottom];
            
            //NSLog(@"action bottom");
        }
        if (self.shouldMoveRightOptions)  {
            [rightOptions runAction:moveBackgroundRight];
            
            //NSLog(@"action right");
        }
    }
    
}

-(void)moveBlockWithTouchLocation:(CGPoint)touchLocation
{
    
    BlockSprite *blockPressed = (BlockSprite *)self.nodePressedAtTouchBegins;
    float autoPositionXBuffer = 0.15;
    float autoPositionYBuffer = 0.2;
    float xPosition = 0;
    float yPosition = 0;
    float middleY = 0;

    blockPressed.position = touchLocation;
    
    for (BlockSprite *block in [self childNodeWithName:blockNodeNameSearch].children) {
        
        
        float blockWidth         = block.frame.size.width/2;
        float blockHeight        = block.frame.size.height/2;
        float blockPressedWidth  = blockPressed.frame.size.width/2;
        float blockPressedHeight = blockPressed.frame.size.height/2;
        
        float blockOffsetXLeft  = block.position.x - blockWidth;
        float blockOffsetXRight = block.position.x + blockWidth;
        float blockOffsetYUp    = block.position.y + blockHeight;
        float blockOffsetYDown  = block.position.y - blockHeight;
        
        float blockPressedOffsetXLeft  = blockPressed.position.x - blockPressedWidth;
        float blockPressedOffsetXRight = blockPressed.position.x + blockPressedWidth;
        float blockPressedOffsetYUp    = blockPressed.position.y + blockPressedHeight;
        float blockPressedOffsetYDown  = blockPressed.position.y - blockPressedHeight;
    
        
        float xBuffer           = block.frame.size.width * autoPositionXBuffer;
        float yBuffer           = block.frame.size.height * autoPositionYBuffer;
        
        
        if (![blockPressed.name isEqualToString:block.name]) {
            
            if ((block.position.x - xBuffer) < blockPressed.position.x  && blockPressed.position.x < (block.position.x + xBuffer)) {
                // center X auto position
                xPosition = block.position.x;
                
            } else if ((blockOffsetXLeft - xBuffer) < blockPressed.position.x  && blockPressed.position.x < (blockOffsetXLeft + xBuffer)) {
                // 1/4 X auto position
                xPosition = blockOffsetXLeft;
                
            } else if ((blockOffsetXRight - xBuffer) < blockPressed.position.x && blockPressed.position.x < (blockOffsetXRight + xBuffer)) {
                // 3/4 x auto position
                xPosition = blockOffsetXRight;
                
            } else if ((blockOffsetXLeft - xBuffer) < blockPressedOffsetXRight && blockPressedOffsetXRight < (blockOffsetXLeft + xBuffer)) {
                // 0/4 x auto position
                xPosition = blockOffsetXLeft - blockWidth;
                
            } else if ((blockOffsetXRight - xBuffer) < blockPressedOffsetXLeft && blockPressedOffsetXLeft < (blockOffsetXRight + xBuffer)) {
                // 4/4 x auto position
                xPosition = blockOffsetXRight + blockWidth;
                
            }
            
            if ( (block.position.y - yBuffer) < blockPressed.position.y  && blockPressed.position.y < (block.position.y + yBuffer) ) {
                // center Y auto position
                yPosition = block.position.y;
            } else if ((blockOffsetYUp - yBuffer) < blockPressed.position.y && blockPressed.position.y < (blockOffsetYUp + yBuffer)) {
                // 1/4 Y auto position
                yPosition = blockOffsetYUp;
                
            } else if ((blockOffsetYDown - yBuffer) < blockPressed.position.y && blockPressed.position.y < (blockOffsetYDown + yBuffer)) {
                // 3/4 y auto position
                yPosition = blockOffsetYDown;
                
            } else if ((blockOffsetYUp - yBuffer) < blockPressedOffsetYDown && blockPressedOffsetYDown < (blockOffsetYUp + yBuffer)) {
                // 0/4 y auto position
                yPosition = blockOffsetYUp + blockHeight;
                
            } else if ((blockOffsetYDown - yBuffer) < blockPressedOffsetYUp &&  blockPressedOffsetYUp < (blockOffsetYDown + yBuffer)) {
                // 4/4 y auto position
                yPosition = blockOffsetYDown - blockHeight;
            }
            
        }
    }
    
    
    for (BlockSprite *block in [self childNodeWithName:blockNodeNameSearch].children) {
        
        float xBuffer           = block.frame.size.width * autoPositionXBuffer;
        float yBuffer           = block.frame.size.height * autoPositionYBuffer;
        
        for (BlockSprite *blockComparitor in [self childNodeWithName:blockNodeNameSearch].children) {
            
            if (![blockComparitor.name  isEqualToString:block.name] && ![blockComparitor.name isEqualToString:blockPressed.name]
                                                                    && ![block.name isEqualToString:blockPressed.name]) {
                //NSLog(@"%f, %f ", block.position.x, blockComparitor.position.x);
                
                if    ((block.position.x - xBuffer) < blockComparitor.position.x && blockComparitor.position.x < (block.position.x + xBuffer)
                    && (block.position.x - xBuffer) < blockPressed.position.x    && blockPressed.position.x    < (block.position.x + xBuffer)) {
                    
                  //  NSLog(@"in the same line as two other blocks");
                
                    if (block.position.y > blockComparitor.position.y) {
                        //NSLog(@"first b y:%f bc y : %f",block.position.y, blockComparitor.position.y);
                    
                        middleY = blockComparitor.position.y + (block.position.y - blockComparitor.position.y);
                    
                        if (blockPressed.position.y < block.position.y && blockPressed.position.y > blockComparitor.position.y) {
                          //  NSLog(@"is inbetween");
                            if ((middleY - yBuffer) < blockPressed.position.y && blockPressed.position.y < (middleY + yBuffer)) {
                                yPosition = middleY;
                                break;
                            }
                        }
                    
                    } else if (block.position.y < blockComparitor.position.y) {
                      //  NSLog(@"second b y:%f bc y : %f",block.position.y, blockComparitor.position.y);
                        middleY = block.position.y + (blockComparitor.position.y - block.position.y);
                    
                        if (blockPressed.position.y < blockComparitor.position.y && blockPressed.position.y > block.position.y) {
                          //  NSLog(@"in between");
                        }
                    }
                }
            }
        }
        if (middleY) {
           // NSLog(@"good a Y exists");
            break;
        }
    }
    
    if(xPosition && yPosition) blockPressed.position = CGPointMake(xPosition, yPosition);
    else if (xPosition) blockPressed.position = CGPointMake(xPosition, touchLocation.y);
    else if (yPosition) blockPressed.position = CGPointMake(touchLocation.x, yPosition);
    //SKShapeNode *line = [SKShapeNode shapeNodeWithPath:CGPathRef ]
        
    
}

-(NSString*)nameBlock
{
    int count = (int)[self childNodeWithName:blockNodeNameSearch].children.count;
    return [NSString stringWithFormat:@"block%d",count];
    
}

-(NSString *)nameBall
{
    int count = (int)[self childNodeWithName:ballNodeNameSearch].children.count;
    return [NSString stringWithFormat:@"ball%d",count];
}

-(NSString *)namePaddle
{
    int count = (int)[self childNodeWithName:paddleNodeNameSearch].children.count;
    return [NSString stringWithFormat:@"paddle%d",count];
}

-(void)switchToMainScene
{
    NSLog(@"switch to main scene");
    [self prepareForSceneChange];
    
    MainScene *mainScene = [[MainScene alloc] initWithSize:self.frame.size];

    [self.view presentScene:mainScene];
}

-(void)switchToStartScene
{
    NSLog(@"switch to start scene");
    [self prepareForSceneChange];
    
    StartScene *startScene = [[StartScene alloc] initWithSize:self.frame.size];
    [self.view presentScene:startScene];
    
}

-(void)prepareForSceneChange
{
    [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        [[GameData sharedGameData].saveFile.blocks removeObject:node];
        BlockSprite *block = (BlockSprite *)node;
        //block.isEditable = NO;
        [block updateSelf];
        block.canBeEdited = NO;
        [[GameData sharedGameData].saveFile.blocks addObject:block];
        [block removeFromParent];

    }];
    
    [[self childNodeWithName:ballNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        [[GameData sharedGameData].saveFile.balls removeObject:node];
        BallSprite *ball = (BallSprite * )node;
        ball.physicsBody.dynamic = YES;
        [[GameData sharedGameData].saveFile.balls addObject:ball];
        [ball removeFromParent];
        
    }];
    
    [[self childNodeWithName:paddleNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        [[GameData sharedGameData].saveFile.paddles removeObject:node];
        PaddleSprite *paddle = (PaddleSprite *)node;
        [[GameData sharedGameData].saveFile.paddles addObject:paddle];
        [paddle removeFromParent];

    }];
    
    [[GameData sharedGameData] archiveSaveFile];
    
    if ([self.view gestureRecognizers]) {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    }
    
    [self removeAllChildren];
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    CGPoint touch         = [sender locationInView:self.view];
    touch.y               = self.frame.size.height - touch.y ;
    SKNode  *nodePressed  = [[self.physicsWorld bodyAtPoint:touch] node];
    
    float halfBlockWidth  = self.nodePressedAtTouchBegins.frame.size.width/2;
    float halfBlockHeight = self.nodePressedAtTouchBegins.frame.size.height/2;
    float blockWidth  = self.nodePressedAtTouchBegins.frame.size.width;
    float blockHeight = self.nodePressedAtTouchBegins.frame.size.height;
    
    if ([self.nodePressedAtTouchBegins.name containsString:blockName]) {
        
        if (nodePressed != self.nodePressedAtTouchBegins) {
            
            CGPoint previousNodeLocation  = self.nodePressedAtTouchBegins.position;
            CGPoint locationForNewBlock   = CGPointMake(self.nodePressedAtTouchBegins.position.x, self.nodePressedAtTouchBegins.position.y);
            
            
            if (previousNodeLocation.x + halfBlockWidth < touch.x) {
                
                locationForNewBlock.x += blockWidth;
                
            } else if (previousNodeLocation.x - halfBlockWidth > touch.x) {
                
                locationForNewBlock.x -= blockWidth;
                
                
            } else if (previousNodeLocation.y + halfBlockHeight < touch.y) {
                
                locationForNewBlock.y += blockHeight;
                
            } else if (previousNodeLocation.y - halfBlockHeight > touch.y) {
                
                locationForNewBlock.y -= blockHeight;
                
            }
            
            BlockSprite *block            = [[BlockSprite alloc] initWithLocation:locationForNewBlock
                                                                        hitPoints:1
                                                                             name:[self nameBlock]
                                                                       hasPowerupType:@""
                                                                      currentSize:@"normal"
                                                                      canBeEdited:YES];
            self.nodePressedAtTouchBegins = block;
            [[self childNodeWithName:blockNodeNameSearch] addChild:block];
        }
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
        self.nodePressedAtTouchBegins = 0;
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    /*
    CGPoint reversedPoint = [sender locationInView:[self view]];
    reversedPoint.y       = self.frame.size.height - reversedPoint.y;
    SKNode  *nodePressed = [[self.physicsWorld bodyAtPoint:reversedPoint] node];
    
    
    if ([nodePressed.name containsString:blockName]) {
        BlockSprite *block = (BlockSprite *)nodePressed;
        
        if (block.isEditable) block.isEditable = NO;
        else if (!block.isEditable) block.isEditable = YES;
        
        [block updateSelf];
        
    } else {
        [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
            
            BlockSprite * block = (BlockSprite *)node;
            block.isEditable    = NO;
            
            [block updateSelf];
        }];
    }
    
    if ([sender state] == UIGestureRecognizerStateEnded) {
        self.nodePressedAtTouchBegins = 0;
    } */

}


-(void)makeAlertWithMessage:(NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0:
            //NSLog(@"no");
            break;
        case 1:
            //NSLog(@"yes");
            
            [self switchToMainScene];
            break;
    }
}


-(BOOL)checkSceneForMissingSprites
{
    NSString *alert = @"Missing: ";
    BOOL missingObject = NO;
    BOOL blocks = [self childNodeWithName:blockNodeNameSearch].children.count;
    BOOL balls =  [self childNodeWithName:ballNodeNameSearch].children.count;
    BOOL paddles = [self childNodeWithName:paddleNodeNameSearch].children.count;
    
    if (!blocks) {
        missingObject = YES;
        alert = [alert stringByAppendingString:@"Blocks "];
    }
    
    if (!balls) {
        missingObject = YES;
        alert = [alert stringByAppendingString:@"Ball "];
    }
    
    if (!paddles) {
        missingObject = YES;
        alert = [alert stringByAppendingString:@"paddle "];
    }
    alert = [alert stringByAppendingString:@" do you want to continue?"];
    
    if (missingObject) {
        [self makeAlertWithMessage:alert];
    }
    
    return missingObject;
}  

-(void)didFinishUpdate
{
    SKNode *node = self.nodePressedAtTouchBegins;
    
    if ([node.name  containsString:blockName]) {
        
        if (![[GameData sharedGameData].saveFile.blocks containsObject:node]) [[GameData sharedGameData].saveFile.blocks addObject:node];
        
    }
    
    if ([node.name containsString:paddleName]) {
        
        if (![[GameData sharedGameData].saveFile.paddles containsObject:node]) [[GameData sharedGameData].saveFile.paddles addObject:node];
        
    }
    
    if ([node.name containsString:ballName]) {
        
        if (![[GameData sharedGameData].saveFile.balls containsObject:node]) [[GameData sharedGameData].saveFile.balls addObject:node];
        
    }
    
}

@end
