//
//  EditGameScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "EditGameScene.h"
#import "BlockSprite.h"
#import "BallSprite.h"
#import "PaddleSprite.h"
#import "MainScene.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameData.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)


static NSString * const overlayBlockName = @"first";
static NSString * const overlayBallName = @"second";
static NSString * const overlayPaddleName = @"third";
static NSString * const rotatePointName = @"rotatePoint";
static NSString * const editPointTopLeftName =  @"editPointTopLeft";
static NSString * const playButtonName = @"play";


@interface EditGameScene ()

@property (nonatomic) SKNode *nodePressedAtTouchBegins;
@property (nonatomic) BlockSprite* rotatingBlock;

@property (nonatomic) float bottomOptionsBuffer;
@property (nonatomic) float rightOptionsBuffer;
@property (nonatomic) float bottomOptionsHeightLimit;
@property (nonatomic) float rightOptionsWidthLimit;
@property (nonatomic) float blockHeight;
@property (nonatomic) float bottomOptionsHeight;

@property (nonatomic) BOOL isAdjustingSize;
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
        
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        self.physicsWorld.gravity         = CGVectorMake(0.0, 0.0);
        self.physicsBody                  = borderBody;
        self.physicsBody.friction         = 0.0;
        self.physicsWorld.contactDelegate = self;
        self.name                         = @"world";
        self.anchorPoint                 = CGPointZero;

        self.bottomOptionsHeightLimit = 110.0;
        self.rightOptionsWidthLimit   = self.frame.size.width - 90.0;
        self.bottomOptionsBuffer      = 100;
        self.rightOptionsBuffer       = 100;
        self.blockHeight              = [[SKSpriteNode alloc] initWithImageNamed:@"block.png"].frame.size.height;
        self.bottomOptionsHeight      = [[SKSpriteNode alloc] initWithImageNamed:@"bottomOptions.png"].frame.size.height;

        [self createBackground];
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
    
    
    [[self view] addGestureRecognizer:tapRecognizer];
    [[self view] addGestureRecognizer:longPressRecognizer];
}


-(void)createBackground
{
    SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
    background.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:background.frame.size];
    background.physicsBody.dynamic = NO;
    background.position       = CGPointZero;
    background.anchorPoint    = CGPointZero;
    background.name           = backgroundName;
    
    [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
}

-(void)createRightOptions
{
    SKSpriteNode *rightOptions = [SKSpriteNode spriteNodeWithImageNamed:@"rightOptions"];
    rightOptions.anchorPoint = CGPointZero;
    rightOptions.position = CGPointMake(self.frame.size.width, 0);
    rightOptions.name = rightOptionsName;
    NSLog(@"screen %f x %f", self.frame.size.width, rightOptions.position.x);
    
    [[self childNodeWithName: optionsNodeNameSearch] addChild:rightOptions];
    
    SKLabelNode *play        = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    play.text                = @"play";
    play.name                = playButtonName;
    play.physicsBody         = [SKPhysicsBody bodyWithRectangleOfSize:play.frame.size];
    play.position            = CGPointMake(rightOptions.frame.size.width/3, rightOptions.frame.size.height/10);
    play.fontSize            = 30;
    play.physicsBody.dynamic = NO;
    [rightOptions addChild:play];
}

-(void)createBottomOptions
{
    
    SKSpriteNode *bottomOptions = [SKSpriteNode spriteNodeWithImageNamed:@"bottomOptions"];
    
    bottomOptions.anchorPoint = CGPointMake(0,0);
    //CGPointMake((bottomOptions.frame.size.width/2) * -1, (bottomOptions.frame.size.height/2));
    bottomOptions.position = CGPointMake(0,bottomOptions.frame.size.height * -1);
    bottomOptions.name = bottomOptionsName;
    NSLog(@"%f, %f", bottomOptions.position.y, bottomOptions.position.x);
    
    
    [[self childNodeWithName:optionsNodeNameSearch] addChild:bottomOptions];
    
    BlockSprite *block = [[BlockSprite alloc] initWithLocation:CGPointMake(bottomOptions.size.width/4, 100)
                                                     hitPoints:1
                                                          name:overlayBlockName
                                                    hasPowerup:NO
                                                   currentSize:@"normal"
                                                   canBeEdited:NO];
    
    BallSprite *ball = [[BallSprite alloc] initWithLocation:CGPointMake(bottomOptions.size.width/2, 100)
                                                currentSize:@"normal"
                                                     status:@"normal"
                                                       name:overlayBallName];
    ball.physicsBody.dynamic = NO;
    
    PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                            position:CGPointMake(bottomOptions.size.width * 3/4, 100)
                                                              status:@"normal"
                                                                name:overlayPaddleName];
    
    [bottomOptions addChild:paddle];
    [bottomOptions addChild:ball];
    [bottomOptions  addChild:block];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    SKNode *node = [self.physicsWorld bodyAtPoint:[[touches anyObject] locationInNode:self]].node;
    
    
    NSLog(@"touch begins pressed %@", node.name);
    
    if (![node.name containsString:blockName] && ![node.name containsString:ballName] &&
        ![node.name containsString:paddleName]) {
        node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    }
    
    NSLog(@"touch begins pressed %@", node.name);


    self.nodePressedAtTouchBegins = node;
 
    if ([node.name isEqualToString:playButtonName]) {
        
        if (![self checkSceneForMissingSprites]) {
            [self switchToMainScene];
        }
    }

}




-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    SKNode  *nodeAtTouch      = [self.physicsWorld bodyAtPoint:touchLocation].node;
 
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayBlockName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        BlockSprite *block            = [[BlockSprite alloc] initWithLocation:touchLocation
                                                                    hitPoints:1
                                                                         name:[self nameBlock]
                                                                   hasPowerup:NO
                                                                  currentSize:@"normal"
                                                                  canBeEdited:YES];
        self.nodePressedAtTouchBegins = block;
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayBallName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        BallSprite *ball = [[BallSprite alloc] initWithLocation:touchLocation
                                                    currentSize:@"normal"
                                                         status:@"normal"
                                                           name:[self nameBall]];
        ball.physicsBody.dynamic = NO;
        self.nodePressedAtTouchBegins = ball;
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
        
    }
    
    if ([self.nodePressedAtTouchBegins.name isEqualToString:overlayPaddleName] && self.nodePressedAtTouchBegins != nodeAtTouch) {
        PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                                position:touchLocation
                                                                  status:@"normal"
                                                                    name:[self namePaddle]];
        self.nodePressedAtTouchBegins = paddle;
        [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    
    }

    if ([self.nodePressedAtTouchBegins.name containsString:ballName]) {
        self.nodePressedAtTouchBegins.position = touchLocation;
    }
    
    if ([self.nodePressedAtTouchBegins.name containsString:paddleName]) {
        self.nodePressedAtTouchBegins.position = touchLocation;
    }
    
    
    if ([self.nodePressedAtTouchBegins.name containsString:blockName]) {
        
        [self moveBlockWithTouchLocation:touchLocation];
    
    }else if ([self.nodePressedAtTouchBegins.name isEqualToString:rotatePointName]) {
        
        BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
        [block adjustRotationWithTouches:touches];
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:editPointTopLeftName]) {
        
        BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
        [block adjustSizeWithTouches:touches];
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:backgroundName] ||
            [self.nodePressedAtTouchBegins.name isEqualToString:bottomOptionsName] ||
             [self.nodePressedAtTouchBegins.name isEqualToString:rightOptionsName]){
        [self adjustOptionMenusWithTouches:touches];
    }
    
}
-(void)didFinishUpdate
{
    SKNode *node = self.nodePressedAtTouchBegins;
    
    if ([node.name  containsString:blockName]) {

        if ([[GameData sharedGameData].blocks containsObject:node]) {
            NSLog(@"sav e data already has block");
            [[GameData sharedGameData].blocks removeObject:node];
            //refresh the block as it moves
            [[GameData sharedGameData].blocks addObject:node];

        } else {
            NSLog(@"save data dosnt have block");
            [[GameData sharedGameData].blocks addObject:node];
        }
    }

    if ([node.name containsString:paddleName]) {
        if ([[GameData sharedGameData].paddles containsObject:node]) {
            NSLog(@"save data already has paddle");
            [[GameData sharedGameData].paddles removeObject:node];
            //refresh the block as it moves
            [[GameData sharedGameData].paddles addObject:node];
            
        } else {
            NSLog(@"save data dosnt have paddle");
            [[GameData sharedGameData].paddles addObject:node];
        }
    }
    
    if ([node.name containsString:ballName]) {
        if ([[GameData sharedGameData].balls containsObject:node]) {
            NSLog(@"save data already has ball");
            [[GameData sharedGameData].balls removeObject:node];
            //refresh the block as it moves
            [[GameData sharedGameData].balls addObject:node];
            
        } else {
            NSLog(@"save data dosnt have ball");
            [[GameData sharedGameData].balls addObject:node];
        }
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"ended");
    if (self.isAdjustingBackground) {
        [self adjustOptionMenusToRest];
    }
    
    if ([self.nodePressedAtTouchBegins.name containsString:blockName]) {
        NSLog(@"a node was created/moved");
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
    NSLog(@"rest");
    SKNode *bottomOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:bottomOptionsName];
    SKNode *rightOptions = [[self childNodeWithName:optionsNodeNameSearch] childNodeWithName:rightOptionsName];
    
    BOOL isBottomOptionsHidden;
    BOOL isRightOptionsHIdden;
    
    float bottomOptionsY  = bottomOptions.position.y + bottomOptions.frame.size.height;
    float rightOptionsX   = rightOptions.position.x;
    
    float bottomOptionsHeight = bottomOptions.frame.size.height;
    float rightOptionsWidth = rightOptions.frame.size.width;
    
    int screenWidth  = self.frame.size.width;
    int screenHeight = self.frame.size.height;
    

    SKAction *slideBottomOptionsUp           = [SKAction moveTo: CGPointMake(0, (self.bottomOptionsHeightLimit - bottomOptionsHeight)) duration:0.5];
    SKAction *slideBottomOptionsDown = [SKAction moveTo:CGPointMake(0.0, -bottomOptionsHeight) duration:0.5];
    SKAction *slideRightOptionsLeft = [SKAction moveTo:CGPointMake(self.rightOptionsWidthLimit, 0.0) duration:0.5];
    SKAction *SlideRightOptionsRight = [SKAction moveTo:CGPointMake(screenWidth, 0) duration:0.5];
    
    
    if (rightOptionsX == screenWidth) {
        NSLog(@"auto move bottom");
        
        if (bottomOptionsY <= self.bottomOptionsHeightLimit/2) {
            [bottomOptions runAction:slideBottomOptionsDown];
            NSLog(@"lower ");
        } else if (bottomOptionsY < (self.bottomOptionsHeightLimit + 60) && bottomOptionsY > (self.bottomOptionsHeightLimit/2)) {
            [bottomOptions runAction:slideBottomOptionsUp];
            NSLog(@"upper");
        }
        
    }
    
    //NSLog(@"x %f  buffer %f", rightOptionsX, self.rightOptionsWidthLimit + 45);
    if (bottomOptionsY == 0) {
        NSLog(@"auto move right");
        if (rightOptionsX >=  self.rightOptionsWidthLimit + 45) {
            NSLog(@"right move to 0");
            [rightOptions runAction:SlideRightOptionsRight];
        
        } else if (rightOptionsX < self.rightOptionsWidthLimit + 45) {
            NSLog(@"right move onto screen");
            [rightOptions runAction:slideRightOptionsLeft];
        }

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
    float bottomOptionsHeight = bottomOptions.frame.size.height;
    float rightOptionsWidth   = rightOptions.frame.size.width;
    
    
    int screenWidth  = self.frame.size.width;
    int screenHeight = self.frame.size.height;
    
    
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
        if (touchLocation.y < bottomOptionsY + self.bottomOptionsBuffer && rightOptionsX == screenWidth) {
            
            self.shouldMoveBottomOptions = YES;
            self.isAdjustingBackground = YES;
            NSLog(@"move botom");
            
        }
        
       //NSLog(@"touch location %f buffer position %f", touchLocation.x, rightOptionsX - self.rightOptionsBuffer);
        
       if (touchLocation.x > rightOptionsX - self.rightOptionsBuffer && bottomOptionsY == 0) {
            
            self.shouldMoveRightOptions = YES;
            self.isAdjustingBackground = YES;
            NSLog(@"move right ");
            
        }
        
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

    
    if (!blockPressed.isEditable) {
        
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
                        
                        NSLog(@"in the same line as two other blocks");
                    
                        if (block.position.y > blockComparitor.position.y) {
                            //NSLog(@"first b y:%f bc y : %f",block.position.y, blockComparitor.position.y);
                        
                            middleY = blockComparitor.position.y + (block.position.y - blockComparitor.position.y);
                        
                            if (blockPressed.position.y < block.position.y && blockPressed.position.y > blockComparitor.position.y) {
                                NSLog(@"is inbetween");
                                if ((middleY - yBuffer) < blockPressed.position.y && blockPressed.position.y < (middleY + yBuffer)) {
                                    yPosition = middleY;
                                    break;
                                }
                            }
                        
                        } else if (block.position.y < blockComparitor.position.y) {
                            NSLog(@"second b y:%f bc y : %f",block.position.y, blockComparitor.position.y);
                            middleY = block.position.y + (blockComparitor.position.y - block.position.y);
                        
                            if (blockPressed.position.y < blockComparitor.position.y && blockPressed.position.y > block.position.y) {
                                NSLog(@"in between");
                            }
                        }
                    }
                }
            }
            if (middleY) {
                NSLog(@"good a Y exists");
                break;
            }
        }
        
        if(xPosition && yPosition) blockPressed.position = CGPointMake(xPosition, yPosition);
        else if (xPosition) blockPressed.position = CGPointMake(xPosition, touchLocation.y);
        else if (yPosition) blockPressed.position = CGPointMake(touchLocation.x, yPosition);
        //SKShapeNode *line = [SKShapeNode shapeNodeWithPath:CGPathRef ]
        
    }
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
    NSMutableArray *blocks = [[NSMutableArray alloc] init];
    NSMutableArray *balls = [[NSMutableArray alloc] init];
    NSMutableArray *paddles = [[NSMutableArray alloc] init];
    
    [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        BlockSprite *block = (BlockSprite *)node;
        block.isEditable = NO;
        [block updateSelf];
        block.canBeEdited = NO;
        [blocks addObject:block];
        [block removeFromParent];
    }];
    
    [[self childNodeWithName:ballNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        BallSprite *ball = (BallSprite * )node;
        [balls addObject:ball];
        [ball removeFromParent];
    }];
    
    [[self childNodeWithName:paddleNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        PaddleSprite *paddle = (PaddleSprite *)node;
        [paddles addObject:paddle];
        [paddle removeFromParent];
    }];
    
    NSArray *sprites = [[NSArray alloc] initWithObjects:blocks,balls,paddles, nil];
    
    MainScene *mainScene = [[MainScene alloc] initWithSize:self.frame.size sprites:sprites];
    
    if ([self.view gestureRecognizers]) {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    }
    
    [self removeAllChildren];
    [self.view presentScene:mainScene];
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
                                                                       hasPowerup:NO
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
    }

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





@end
