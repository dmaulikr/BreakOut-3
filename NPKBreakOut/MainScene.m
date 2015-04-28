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
#import "GameSaveFile.h"



static NSString * const saveAndQuitLabelName = @"saveAndQuit";
static NSString * const continueLabelName   = @"continue";
static NSString * const pausedScreenName = @"pausedScreen";

@interface MainScene ()

@property (nonatomic) BOOL isGamePlaying;
@property (nonatomic) int doubleBallDuration;
@property (nonatomic) NSMutableArray *nodesPressedAtTouchBegins;


@end

@implementation MainScene


-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        [self addChild:[super createNodeTree]];
        [super setupSaveFile];

        
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        //borderBody.categoryBitMask = borderCategory;
        SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        CGRect bottomRect         = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        SKNode *bottom            = [SKNode node];
        
        self.nodesPressedAtTouchBegins    = [[NSMutableArray alloc] init];
        self.physicsWorld.gravity         = CGVectorMake(0.0, 0.0);
        self.physicsWorld.speed           = 0;
        self.physicsWorld.contactDelegate = self;
        self.scaleMode                    = SKSceneScaleModeResizeFill;
        self.userInteractionEnabled       = YES;
        self.physicsBody                  = borderBody;
        self.physicsBody.friction         = 0.0;
        
        self.doubleBallDuration = 4;

        background.position               = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        background.name                   = backgroundName;
        bottom.physicsBody                = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        bottom.physicsBody.categoryBitMask= bottomCategory;
        self.isGamePlaying                = NO;
        
        
        [[self childNodeWithName:overlayNodeNameSearch] addChild:bottom];
        [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
        
        [self createContents];
        [self startGameIsFirstTime:YES];
        
    }
    return self;
}




-(void)createContents
{
    if ([GameData sharedGameData].saveFile.blocks.count > 0) [self createBlocksFromData];
    else                                            [self createDefaultBlocks];
    
    
    if ([GameData sharedGameData].saveFile.paddles.count > 0) [self createPaddlesFromData];
    else                                             [self createDefaultPaddle];
    
    if ([GameData sharedGameData].saveFile.balls.count > 0) [self createBallsFromData];
    else                                           [self createDefaultBall];
    
    if ([GameData sharedGameData].saveFile.powerUps.count > 0) [self createPowerUpFromData];
    
}

-(void)createBlocksFromData
{
    //NSLog(@"create blocks from data");
    for (BlockSprite *block in [GameData sharedGameData].saveFile.blocks) {
        block.physicsBody.categoryBitMask = blockCategory;
        
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
    }
}

-(void)createBallsFromData
{
    for (BallSprite *ball in [GameData sharedGameData].saveFile.balls) {

        ball.physicsBody.dynamic = YES;
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
        ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory | ballCategory | borderCategory;
        

        
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    }
}


-(void)createPaddlesFromData
{
    
    CGVector movingAngle;
    
    for (PaddleSprite *paddle in [GameData sharedGameData].saveFile.paddles) {
        
        paddle.physicsBody.contactTestBitMask = powerUpCategory;
        paddle.physicsBody.collisionBitMask   = blockCategory;
        paddle.physicsBody.dynamic = YES;
        
        [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
        
        if (paddle.zRotation == 0.00 || roundf(paddle.zRotation*100)/100 == roundf(M_PI)) {
            NSLog(@"horizontal paddle");
            movingAngle = CGVectorMake(50, 0);
            
        } else if (roundf(paddle.zRotation *100)/100 == -roundf((M_PI/2)*100)/100
                   || roundf(self.zRotation *100)/100 == roundf((M_PI/2)*100)/100) {
            NSLog(@"vertical paddle");
            movingAngle = CGVectorMake(0, 50);
        }
        
        SKPhysicsJointSliding *joint = [SKPhysicsJointSliding jointWithBodyA:paddle.physicsBody
                                                                       bodyB:self.physicsBody
                                                                      anchor:CGPointZero
                                                                        axis:CGVectorMake(50, -50)];
        [self.physicsWorld addJoint:joint];
        
        
    }
    
}



-(void)createPowerUpFromData
{
    for (PowerUpSprite *powerUp in [GameData sharedGameData].saveFile.powerUps) {
        [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUp];
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
                                                       name:[self nameSpriteWithType:ballName]];
    
    
    ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
    ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory | ballCategory | borderCategory;
    
    [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    [[GameData sharedGameData].saveFile.balls addObject:ball];
}

-(void)createDoubleBall
{
    if ([self childNodeWithName:ballNodeNameSearch].children.count <= 1) {
        
        BallSprite *originalBall = (BallSprite *)[[self childNodeWithName:ballNodeNameSearch] childNodeWithName:@"*"];
        CGPoint originalPosition;
        CGVector originalVector;
        
        
        BallSprite *ball = [[BallSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/3, self.frame.size.height/3)
                                                    currentSize:@"normal"
                                                         status:@"normal"
                                                           name:[self nameSpriteWithType:ballName]];
        
        if (originalBall) {
            originalPosition = originalBall.position;
            originalVector = originalBall.physicsBody.velocity;
            ball.position = CGPointMake(originalPosition.x - 20, originalPosition.y - 20);
            ball.physicsBody.velocity = originalVector;
        }

        
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
        ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory | ballCategory;
        SKAction *wait = [SKAction waitForDuration:self.doubleBallDuration];
        SKAction *fade = [SKAction fadeOutWithDuration:2];
        SKAction *remove = [SKAction runBlock:^{
            [ball removeFromParent];
            [[GameData sharedGameData].saveFile.balls removeObject:ball];
        }];
        SKAction *waitThenFade = [SKAction sequence:@[wait,fade,remove]];
        [ball runAction:waitThenFade];

        
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
        [[GameData sharedGameData].saveFile.balls addObject:ball];
    }

}

-(void)createDefaultPaddle
{
    PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                            position:CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.05)
                                                              status:@"normal"
                                                                name:[self nameSpriteWithType:paddleName]];
    
    paddle.physicsBody.contactTestBitMask = powerUpCategory;
    paddle.physicsBody.collisionBitMask   = blockCategory;
    paddle.physicsBody.dynamic = YES;

    
    [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    [[GameData sharedGameData].saveFile.paddles addObject:paddle];
    
    

    
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
        NSString *hasPowerUpType = @"";
        if (hasPowerup) {
            if ([GameScene getYesOrNo]) {
                hasPowerUpType = powerUpBigBall;
            } else {
                hasPowerUpType = powerUpDoubleBall;
            }
        }
        float xOffset      = (self.frame.size.width - (blockWidth * numberOfBlocks + padding * (numberOfBlocks-1))) / 2;
        BlockSprite *block = [[BlockSprite alloc] initWithLocation:CGPointMake((i-0.5)*blockWidth + (i-1)*padding + xOffset,locationY)
                                                         hitPoints:hitPoints
                                                              name:[self nameSpriteWithType:blockName]
                                                        hasPowerupType:hasPowerUpType
                                                       currentSize:@"normal"
                                                       canBeEdited:NO];
        
        
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
        [[GameData sharedGameData].saveFile.blocks addObject:block];
    }
    
}





-(void)startGameIsFirstTime:(BOOL)isFirstTime
{
    BOOL firstTime = isFirstTime;
    
    for (BallSprite *ball in [self childNodeWithName:ballNodeNameSearch].children) {
        if (ball.physicsBody.velocity.dy || ball.physicsBody.velocity.dx) {
            firstTime = NO;
        }
    }


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
                
                if (firstTime) {
                    [[self childNodeWithName:ballNodeNameSearch] enumerateChildNodesWithName:@"*"
                                                                                  usingBlock:^(SKNode *node, BOOL *stop) {
                        [node.physicsBody applyImpulse:CGVectorMake(-10.0, 10.0)];
                    }];
                }
                [[GameData sharedGameData] archiveSaveFile];
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
        
        
        
        if ([node.name containsString:backgroundName]) {
            [self pauseGame];
        }
        
        if ([node.name containsString:continueLabelName]) {
            
            [[node parent] removeFromParent];
        
            //NSLog(@"unpausing");
            
            self.paused = NO;
            [self childNodeWithName:powerUpNodeNameSearch].paused = YES;

            if (self.isGamePlaying) {
                
                //NSLog(@"count down is over ~ run start game");
                
                self.isGamePlaying = NO;
                [self startGameIsFirstTime:NO];

            } else {
                //NSLog(@"countdown on screen ~ resume game");
                // game is note playing
                self.physicsWorld.speed = 1.0;
                
            }
        }


        if ([node.name isEqualToString:saveAndQuitLabelName]) {
            [[GameData sharedGameData] archiveSaveFile];
            [self removeAllChildren];
            [GameData sharedGameData].saveFile = [[GameSaveFile alloc] init];
            
            StartScene *startScene = [[StartScene alloc] initWithSize:self.size];
            [self.view presentScene:startScene];
            
        }
        
        if ([node.name isEqualToString:blockNodeName]
            || [node.name isEqualToString:powerUpNodeName]
            || [node.name isEqualToString:ballNodeName]
            || [node.name isEqualToString:paddleNodeName]) {
            self.nodesPressedAtTouchBegins = nil;
        }

    }
    NSLog(@"node at pressed begins %@", (SKSpriteNode *)[self.nodesPressedAtTouchBegins firstObject]);

    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.nodesPressedAtTouchBegins.count == 1) {

        SKSpriteNode *sprite = (SKSpriteNode *)[self.nodesPressedAtTouchBegins firstObject];
        if ([sprite.name containsString:paddleName]) {
            [self movePaddle:(PaddleSprite *)sprite withTouches:touches];
        }

    } else if (self.nodesPressedAtTouchBegins.count == 2) {
        NSLog(@"more then one pressed");
        /*
        
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
        } */
    }

}

-(void)movePaddle:(PaddleSprite*)paddle withTouches:(NSSet *)touches
{
    
    if (paddle.zRotation == 0.00 || roundf(paddle.zRotation*100)/100 == roundf(M_PI)) {
        NSLog(@"horizontal paddle");
        [self movePaddle:paddle horizontallyWithTouches:touches];
        
    } else if (roundf(paddle.zRotation *100)/100 == -roundf((M_PI/2)*100)/100
               || roundf(self.zRotation *100)/100 == roundf((M_PI/2)*100)/100) {
        NSLog(@"vertical paddle");
    }
    

    //paddle.position = CGPointMake(touchLocation.x, paddle.position.y);
    
}

-(void)movePaddle:(PaddleSprite *)paddle horizontallyWithTouches:(NSSet *)touches
{
    CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    CGPoint previousTouch = [[touches anyObject] previousLocationInNode:self];

    if (touchLocation.x > paddle.size.width/2
        && touchLocation.x < self.scene.size.width - paddle.size.width/2) {
        
        // within the scene so ok to move
        paddle.position =  CGPointMake(touchLocation.x, paddle.position.y);

        
        for (BlockSprite *block in [self childNodeWithName:blockNodeNameSearch].children) {
            // checking to see if there is a block in the way
            
            if ((paddle.position.y + paddle.size.height/2) > (block.position.y - block.size.height/2)
                && paddle.position.y - paddle.size.height/2 < (block.position.y + block.size.height/2)) {
                //on the same line as a block

                float touchTravelDistance =  previousTouch.x - touchLocation.x;
                //NSLog(@"were to move to %f", (touchTravelDistance + (paddle.position.x + paddle.size.width/2))+ 10);
                //NSLog(@"where paddle is %f", paddle.position.x + paddle.size.width/2);
                //NSLog(@"where block is %f", (block.position.x - block.size.width/2));
                if ((touchTravelDistance + (paddle.position.x + paddle.size.width/2)) < (block.position.x - block.size.width/2)) {
                    NSLog(@"moving paddle");
                    paddle.position =  CGPointMake(touchLocation.x, paddle.position.y);
            
                    
                }
                    //paddle.position = CGPointMake(touchLocation.x, paddle.position.y);

                
                
                //touchTravelDistance + (paddle.position.x - paddle.size.width/2) - 10 < (block.position.x + block.size.width/2)
                
                /*
                if (paddle.position.x + paddle.size.width/2 < ((block.position.x - block.size.width/2)+ 5)
                    || paddle.position.x - paddle.size.width/2 > ((block.position.x + block.size.width/2) +3)) {
                    
                    NSLog(@"block inline but not to close");
                    
                    paddle.position = CGPointMake(touchLocation.x, paddle.position.y);


                } else  {
                    NSLog(@"block inline but way to close");
                    if (paddle.position.x + paddle.size.width/2 < ((block.position.x - block.size.width/2) + 10)
                        ||paddle.position.x + paddle.size.width/2 < ((block.position.x - block.size.width/2) - 10)) {
                        //should only move paddle to the left -x value
                        if ((touchLocation.x - previousTouch.x) <= 0) {
                            paddle.position = CGPointMake(touchLocation.x, paddle.position.y);

                        }
                    }
                } */
            }
        }
        if (touchLocation.x) {
            
        }
    }
}

-(void)movePaddle:(PaddleSprite *)paddle verticallyWithTouches:(NSSet *)touches
{
    CGPoint touchLocation = [[touches anyObject] locationInNode:self];

    if (touchLocation.y > paddle.size.width/2
        && touchLocation.y < self.size.height - paddle.size.width/2) {
        paddle.position = CGPointMake(paddle.position.x, touchLocation.y);
        
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    PaddleSprite *paddle = (PaddleSprite *)[self.nodesPressedAtTouchBegins firstObject];
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
        
        if ([powerUp.type isEqualToString:powerUpDoubleBall]) {
            [self createDoubleBall];
        } else if ([powerUp.type isEqualToString:powerUpBigBall]) {
            BallSprite *ball = (BallSprite *)[[self childNodeWithName:ballNodeNameSearch] childNodeWithName:@"*"];
            ball.currentSize = @"big";
            
            [ball updateSize];
        }
        
        [powerUp removeFromParent];
        [[GameData sharedGameData].saveFile.powerUps removeObject:powerUp];
        

        [[GameData sharedGameData] archiveSaveFile];
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
            if (![block.powerUpType isEqualToString:@""]) {
                [self createPowerUpWithLocation:block.position type:block.powerUpType];
                
            }
            [block removeFromParent];
            [[GameData sharedGameData].saveFile.blocks removeObject:block];
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



-(NSString *)nameSpriteWithType:(NSString *)type
{
    int count = 0;
    
    if ([type isEqualToString:blockName]) {
        count = (int)[self childNodeWithName:blockNodeNameSearch].children.count;
    } else if ([type isEqualToString:ballName]) {
        count = (int)[self childNodeWithName:ballNodeNameSearch].children.count;
    } else if ([type isEqualToString:paddleName]) {
        count = (int)[self childNodeWithName:paddleNodeNameSearch].children.count;
    } else if ([type isEqualToString:powerUpName]) {
        count = (int)[self childNodeWithName:powerUpNodeNameSearch].children.count;
    }
    
    return [NSString stringWithFormat:@"%@%d",type, count];
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


-(void)createPowerUpWithLocation:(CGPoint)location type:(NSString *)type
{
    PowerUpSprite *powerUpSprite                  = [[PowerUpSprite alloc] initWithLocation:location
                                                                                       type:type
                                                                                       name:powerUpName
                                                                                 shouldMove:YES];
    powerUpSprite.physicsBody.collisionBitMask    = paddleCategory | bottomCategory;
    powerUpSprite.physicsBody.contactTestBitMask  = paddleCategory | bottomCategory;
    powerUpSprite.physicsBody.dynamic = YES;
    
    [[self childNodeWithName:powerUpNodeNameSearch] addChild:powerUpSprite];
    [[GameData sharedGameData].saveFile.powerUps addObject:powerUpSprite];
    
}


    
@end
