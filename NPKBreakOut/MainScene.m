//
//  MainScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/12/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "MainScene.h"
#import "GameOverScene.h"
#import "BlockSprite.h"
#import "PowerUpSprite.h"
#import "PaddleSprite.h"
#import "BallSprite.h"
#import "Constants.h"
#import "GameData.h"
#import "StartScene.h"

static const uint32_t ballCategory    = 0x1 << 0;
static const uint32_t blockCategory   = 0x1 << 2;
static const uint32_t paddleCategory  = 0x1 << 3;
static const uint32_t bottomCategory  = 0x1 << 1;
static const uint32_t powerUpCategory = 0x1 << 4;

static NSString * const saveAndQuitLabelName = @"saveAndQuit";
static NSString * const continueLabelName   = @"continue";
static NSString * const pausedScreenName = @"pausedScreen";

@interface MainScene ()

@property (nonatomic) BOOL isGamePlaying;
@property (nonatomic) NSMutableArray *nodesPressedAtTouchBegins;


@end

@implementation MainScene

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        [self addChild:[super createNodeTree]];
        
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        CGRect bottomRect         = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        SKNode *bottom            = [SKNode node];
        
        self.nodesPressedAtTouchBegins    = [[NSMutableArray alloc] init];
        self.physicsWorld.gravity         = CGVectorMake(0.0, 0.0);
        self.scaleMode                    = SKSceneScaleModeResizeFill;
        self.userInteractionEnabled       = YES;
        self.physicsBody                  = borderBody;
        self.physicsBody.friction         = 0.0;
        self.physicsWorld.contactDelegate = self;
        background.position               = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        background.name                   = backgroundName;
        bottom.physicsBody                = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        bottom.physicsBody.categoryBitMask= bottomCategory;
        self.isGamePlaying                = NO;

        
        [[self childNodeWithName:overlayNodeNameSearch] addChild:bottom];
        [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
        
        NSLog(@"main scene init ");
        
        if ([[GameData sharedGameData].saveFileName isEqualToString:@""]) {
            NSLog(@"starting,  main scene has no saveFileName");
            NSDate *now = [NSDate date];
            [GameData sharedGameData].saveFileName = [now description];
            [[GameData sharedGameData] saveWithFileName:[GameData sharedGameData].saveFileName];
        } else {
            NSLog(@"starting, main scene Has savefile");
        }
        
        [self createContents];
        [self startGameIsFirstTime:YES];
        
        
    }
    
    return self;
}
-(void)createContents
{
    
    
    if ([GameData sharedGameData].blocks.count > 0) [self createBlocksFromData];
    else                                            [self createDefaultBlocks];
    
    
    if ([GameData sharedGameData].paddles.count > 0) [self createPaddlesFromData];
    else                                             [self createDefaultPaddle];
    
    if ([GameData sharedGameData].balls.count > 0) [self createBallsFromData];
    else                                           [self createDefaultBall];
    
    if ([GameData sharedGameData] > 0) [self createPowerUpFromData];
    
}

-(void)createBlocksFromData
{
    NSLog(@"create blocks from data");
    for (BlockSprite *block in [GameData sharedGameData].blocks) {
        
        block.physicsBody.dynamic         = NO;
        block.physicsBody.categoryBitMask = blockCategory;
        //block.zPosition = 1.0;
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
    }
}

-(void)createBallsFromData
{
    for (BallSprite *ball in [GameData sharedGameData].balls) {
        ball.physicsBody.dynamic         = YES;
        ball.physicsBody.categoryBitMask    = ballCategory;
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
        ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory | ballCategory;
        
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    }
}


-(void)createPaddlesFromData
{
    for (PaddleSprite *paddle in [GameData sharedGameData].paddles) {
        
        paddle.physicsBody.categoryBitMask    = paddleCategory;
        paddle.physicsBody.contactTestBitMask = powerUpCategory;
        
        [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    }
    
}


-(void)createDefaultBlocks
{
    float padding          = 5.0;
    float blockHeight      = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"].size.height;
    float currentLocationY = self.frame.size.height - (blockHeight/2) - padding;
    
    for (int  i = 0; i < 5; i++) {
        [self createLineOfBlocksWithLocationY:currentLocationY
                                      padding:padding
                               numberOfBlocks:4];
        currentLocationY = currentLocationY - (blockHeight) - padding;
    }
    
}



-(void)createDefaultBall
{
    BallSprite *ball = [[BallSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/3, self.frame.size.height/3)
                                                currentSize:@"normal"
                                                     status:@"normal"
                                                       name:ballName];
    
    
    ball.physicsBody.categoryBitMask    = ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
    ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory;
    
    [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    [[GameData sharedGameData].balls addObject:ball];
}

-(void)createDefaultPaddle
{
    PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                            position:CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.05)
                                                              status:@"normal"
                                                                name:paddleName];
    
    paddle.physicsBody.categoryBitMask    = paddleCategory;
    paddle.physicsBody.contactTestBitMask = powerUpCategory;
    
    [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    [[GameData sharedGameData].paddles addObject:paddle];
    
}

-(void)createLineOfBlocksWithLocationY:(float)locationY padding:(float)padding numberOfBlocks:(int)numberOfBlocks
{
    
    int blockWidth                = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"].size.width;
    NSMutableArray *randomNumbers = [self selectRandomBlocksWithAmount:arc4random_uniform(4)];
    
    for (int i = 1; i <= numberOfBlocks; i++) {
        BOOL hasPowerup  = NO;
        int  hitPoints   = 1;
        
        for (int  p = 0; p < randomNumbers.count; p++) {
            if ([[randomNumbers objectAtIndex:p] intValue]== i) {
                hasPowerup = YES;
                hitPoints  = 3;
                
            }
        }
        float xOffset      = (self.frame.size.width - (blockWidth * numberOfBlocks + padding * (numberOfBlocks-1))) / 2;
        BlockSprite *block = [[BlockSprite alloc] initWithLocation:CGPointMake((i-0.5)*blockWidth + (i-1)*padding + xOffset,locationY)
                                                         hitPoints:hitPoints
                                                              name:[self nameBlock]
                                                        hasPowerup:hasPowerup
                                                       currentSize:@"normal"
                                                       canBeEdited:NO];
        
        block.physicsBody.categoryBitMask = blockCategory;
        
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
        [[GameData sharedGameData].blocks addObject:block];
    }
    
}

-(void)createPowerUpFromData
{
    for (PowerUpSprite *powerUp in [GameData sharedGameData].powerUps) {
        [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUp];
    }
}

-(void)createPowerUpWithLocation:(CGPoint)location
{
    PowerUpSprite *powerUpSprite                  = [[PowerUpSprite alloc] initWithLocation:location
                                                                                       type:@"bigBall"
                                                                                       name:powerUpName];
    powerUpSprite.physicsBody.categoryBitMask     = powerUpCategory;
    powerUpSprite.physicsBody.collisionBitMask    = paddleCategory | bottomCategory;
    powerUpSprite.physicsBody.contactTestBitMask  = paddleCategory | bottomCategory;
    
    [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUpSprite];
    [[GameData sharedGameData].powerUps addObject:powerUpSprite];
    
}


-(void)startGameIsFirstTime:(BOOL)isFirstTime
{
    //NSLog(@"start game");

    SKLabelNode *timer = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    timer.text         = @"3";
    timer.fontSize     = 40;
    timer.fontColor    = [UIColor blackColor];
    timer.position     = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    [[self childNodeWithName:overlayNodeNameSearch] addChild:timer];
    
    
    SKAction *fadeIn       = [SKAction fadeInWithDuration:0.3];
    SKAction *shrinkTiny   = [SKAction scaleTo:0.01 duration:0.0];
    SKAction *growToNormal = [SKAction scaleTo:1 duration:0.3];
    SKAction *fadeOut      = [SKAction fadeOutWithDuration:0.7];
    
    SKAction *growFadeIn    = [SKAction group:@[fadeIn, growToNormal]];
    SKAction *fadeOutShrink = [SKAction sequence:@[fadeOut, shrinkTiny]];
    SKAction *runAnimation  = [SKAction sequence:@[growFadeIn, fadeOutShrink]];
    
    [timer runAction:runAnimation completion:^{
        timer.text = @"2";
        [timer runAction:runAnimation completion:^{
            timer.text = @"1";
            [timer runAction:runAnimation completion:^{
                timer.text = @"GO!";
                
                self.physicsWorld.speed = 1.0;
                self.isGamePlaying      = YES;
                [self childNodeWithName:powerUpNodeNameSearch].paused = NO;
                
                if (isFirstTime) {
                    [[self childNodeWithName:ballNodeNameSearch] enumerateChildNodesWithName:@"*"
                                                                                  usingBlock:^(SKNode *node, BOOL *stop) {
                        [node.physicsBody applyImpulse:CGVectorMake(-10.0, 10.0)];
                    }];
                }
                NSDate *date = [NSDate date];
                [[GameData sharedGameData] saveWithFileName:[date description]];
                [timer runAction:runAnimation completion:^{
                    [timer removeFromParent];
                }];
            }];
        }];
    }];
    
}

-(void)pauseGame
{
    
    //NSLog(@"pausing");
    
    SKSpriteNode *pausedScreen     = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:self.frame.size];
    pausedScreen.anchorPoint    = CGPointZero;
    pausedScreen.alpha          = 0.5;
    pausedScreen.name           = pausedScreenName;
    
    SKLabelNode *saveLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    saveLabel.text = @"Save And Quit";
    saveLabel.fontSize = 30;
    saveLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/5);
    saveLabel.name = saveAndQuitLabelName;
    
    SKLabelNode *continueLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    continueLabel.text = @"Continue";
    continueLabel.fontSize = 30;
    continueLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/8);
    continueLabel.name = continueLabelName;
    
    
    [pausedScreen addChild:continueLabel];
    [pausedScreen addChild:saveLabel];
    [[self childNodeWithName:overlayNodeNameSearch] addChild:pausedScreen];
    
    self.physicsWorld.speed = 0.0;
    self.paused = YES;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    for (UITouch *touch in touches) {
        
        CGPoint touchLocation = [touch locationInNode:self];
        SKNode *node = [self.physicsWorld bodyAtPoint:touchLocation].node;
        
        if ([node.name containsString:paddleName]) {
           // NSLog(@"paddle touched");
            if (!self.paused) {
                [self.nodesPressedAtTouchBegins addObject:node];
            }
            
        } else {
            node = [self nodeAtPoint:touchLocation];
        }
        
        //NSLog(@"node at pressed begins %@", node.name);
        
        
        if ([node.name containsString:backgroundName]) {
            [self pauseGame];
        }
        
        if ([node.name containsString:continueLabelName]) {
            
            [[node parent] removeFromParent];
        
            NSLog(@"unpausing");
            
            self.paused = NO;
            [self childNodeWithName:powerUpNodeNameSearch].paused = YES;

            if (self.isGamePlaying) {
                
                NSLog(@"count down is over ~ run start game");
                
                self.isGamePlaying = NO;
                [self startGameIsFirstTime:NO];

            } else {
                NSLog(@"countdown on screen ~ resume game");
                // game is note playing
                self.physicsWorld.speed = 1.0;
                
            }
        }


        if ([node.name isEqualToString:saveAndQuitLabelName]) {
            NSDate *date = [NSDate date];
            [[GameData sharedGameData] resaveGameData];
            [self  removeAllChildren];
            [[GameData sharedGameData] reset];
            StartScene *startScene = [[StartScene alloc] initWithSize:self.size];
            [self.view presentScene:startScene];
            
        }

    
   
    }
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.nodesPressedAtTouchBegins.count == 1) {
        NSLog(@"moving paddle");
        
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        CGPoint previousLocation = [[touches anyObject] previousLocationInNode:self];
        
        //NSLog(@"more then 0 ");
        SKNode *firstNodePressed = [self.nodesPressedAtTouchBegins firstObject];

        int paddleX = firstNodePressed.position.x + (touchLocation.x - previousLocation.x);
        
        paddleX = MAX(paddleX, firstNodePressed.frame.size.width/2);
        paddleX = MIN(paddleX, self.size.width - firstNodePressed.frame.size.width/2);
        
        firstNodePressed.position = CGPointMake(paddleX, firstNodePressed.position.y);

    } else if (self.nodesPressedAtTouchBegins.count == 2) {
        NSLog(@"more then one pressed");
        
        for (UITouch *touch in touches) {
            CGPoint touchLocation = [touch locationInNode:self];
            CGPoint previousLocation = [touch previousLocationInNode:self];
            SKNode *nodeTouched = [self nodeAtPoint:touchLocation];
            //NSLog(@"node touched %@",nodeTouched.name);
            
            for (SKNode *touchBeginsNode in self.nodesPressedAtTouchBegins) {
                NSLog(@"node touched at begin %@ node touched %@",touchBeginsNode.name, nodeTouched.name);

                if ([nodeTouched.name isEqualToString:touchBeginsNode.name]) {
                    int paddleX              = touchBeginsNode.position.x + (touchLocation.x - previousLocation.x);
                    
                    paddleX = MAX(paddleX, touchBeginsNode.frame.size.width/2);
                    paddleX = MIN(paddleX, self.size.width - touchBeginsNode.frame.size.width/2);
                    
                    touchBeginsNode.position = CGPointMake(paddleX, touchBeginsNode.position.y);
                    
                }
            }
        }
    }
    //NSMutableArray *nodesPressedAtTouchBegins = self.nodesPressedAtTouchBegins;
    //SKNode *node = nodesPressedAtTouchBegins[0];
    
    
    /*
    if ([node.name containsString:paddleName]) {

        PaddleSprite *paddle     = (PaddleSprite *) self.nodesPressedAtTouchBegins;
        int paddleX              = paddle.position.x + (touchLocation.x - previousLocation.x);
        
        paddleX = MAX(paddleX, paddle.size.width/2);
        paddleX = MIN(paddleX, self.size.width - paddle.size.width/2);
        
        paddle.position = CGPointMake(paddleX, paddle.position.y);
    } */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.nodesPressedAtTouchBegins = [[NSMutableArray alloc] init];
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody  = contact.bodyA;
        secondBody = contact.bodyB;
    } else
    {
        firstBody  = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory)
    {
        GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:NO];
        
        //[self.view presentScene:gameOverScene];
    }
    
    if (firstBody.categoryBitMask == bottomCategory && secondBody.categoryBitMask == powerUpCategory) {
        [secondBody.node removeFromParent];
    }
    
    if (firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == powerUpCategory) {
        PowerUpSprite *powerUp = (PowerUpSprite *)secondBody.node;
        
        [powerUp removeFromParent];
        [[GameData sharedGameData].powerUps removeObject:powerUp];
        
        BallSprite *ball = (BallSprite *)[[self childNodeWithName:ballNodeNameSearch] childNodeWithName:ballName];
        ball.currentSize = @"big";
        
        [ball updateSelf];
    }
    
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory) {
        
        BlockSprite *block = (BlockSprite *)secondBody.node;
        
        if (block.hitPoints == 3) {
            block.hitPoints--;
            [block updateSelf];
        }else if (block.hitPoints == 2) {
            block.hitPoints--;
            [block updateSelf];
        } else if (block.hitPoints == 1) {
            if (block.hasPowerup) {
                [self createPowerUpWithLocation:block.position];
            }
            [block removeFromParent];
            [[GameData sharedGameData].blocks removeObject:block];
        }
        
        if ([self childNodeWithName:blockNodeNameSearch].children.count <= 0) {
            GameOverScene *gameWonScene = [[GameOverScene alloc]
                                           initWithSize:self.frame.size playerWon:YES];
            [self.view presentScene:gameWonScene];
        }
        
    }
}

-(void)didChangeSize:(CGSize)oldSize
{
    //NSLog(@"changed size adjust scene");
    
}

-(void)update:(NSTimeInterval)currentTime
{
    SKNode *ball = [[self childNodeWithName:ballNodeNameSearch] childNodeWithName:ballName];
    static int maxSpeed = 1000;
    float speed = sqrt(ball.physicsBody.velocity.dx * ball.physicsBody.velocity.dx +
                       ball.physicsBody.velocity.dy * ball.physicsBody.velocity.dy);
    
    if (abs(ball.physicsBody.velocity.dx) < 60 && self.isGamePlaying) {
        //NSLog(@"x is slow %f", ball.physicsBody.velocity.dx);
        
        [ball.physicsBody applyImpulse:CGVectorMake(3, 0)];
        //NSLog(@"x speed increease %f", ball.physicsBody.velocity.dx * .001);
        
    }
    
    if (abs(ball.physicsBody.velocity.dy) < 75 && self.isGamePlaying) {
        //NSLog(@"y is slow %f", ball.physicsBody.velocity.dy);
        
        [ball.physicsBody applyImpulse:CGVectorMake(0, 3)];
        //NSLog(@"y speed increease %f", ball.physicsBody.velocity.dy * .001);
        
    }
    
    if(speed > maxSpeed)
    {
        ball.physicsBody.linearDamping = 0.4;
    } else
    {
        ball.physicsBody.linearDamping = 0.0;
    }
}



-(NSString*)nameBlock
{
    int count = (int)[self childNodeWithName:blockNodeNameSearch].children.count;
    if (count <= 0) {
        count = 1;
    }
    return [NSString stringWithFormat:@"block%d",count];
    
}

-(NSMutableArray *)selectRandomBlocksWithAmount:(int)amount
{
    NSMutableArray *tempNumbers = [[NSMutableArray alloc] init];
    if (amount) {
        
        int randomNumber;
        
        NSMutableArray *remainingNumbers = [NSMutableArray array];
        for (int i = 1; i <= 4; i++) {
            [remainingNumbers addObject:[NSNumber numberWithInt:i]];
        }
        
        for (int i = 0; i < amount; i++) {
            float maxIndex = [remainingNumbers count];
            randomNumber = arc4random_uniform(maxIndex);
            
            [tempNumbers addObject:[remainingNumbers objectAtIndex:randomNumber]];
            [remainingNumbers removeObjectAtIndex:randomNumber];
        }
    }
    
    return tempNumbers;
    
}



    
@end
