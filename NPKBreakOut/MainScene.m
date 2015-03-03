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

static const uint32_t ballCategory    = 0x1 << 0;
static const uint32_t blockCategory   = 0x1 << 2;
static const uint32_t paddleCategory  = 0x1 << 3;
static const uint32_t bottomCategory  = 0x1 << 1;
static const uint32_t powerUpCategory = 0x1 << 4;


@interface MainScene ()

@property (nonatomic) BOOL isFingerOnPaddle;
@property (nonatomic) BOOL isGamePlaying;


@end

@implementation MainScene

-(instancetype)initWithSize:(CGSize)size sprites:(NSArray *)sprites
{
    if (self = [super initWithSize:size]) {
        
        [self addChild:[super createNodeTree]];
        
        SKPhysicsBody *borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        CGRect bottomRect         = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        SKNode *bottom            = [SKNode node];
        
        self.physicsWorld.gravity         = CGVectorMake(0.0, 0.0);
        self.scaleMode                    = SKSceneScaleModeResizeFill;
        self.userInteractionEnabled       = YES;
        self.physicsBody                  = borderBody;
        self.physicsBody.friction         = 0.0;
        self.physicsWorld.contactDelegate = self;
        background.position               = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        bottom.physicsBody                = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        bottom.physicsBody.categoryBitMask= bottomCategory;
        
        [[self childNodeWithName:overlayNodeNameSearch] addChild:bottom];
        [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
        NSLog(@"sprites count %lu", self.view.gestureRecognizers.count);
        
        
        [self createContentsWithSprites:sprites];
        
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTap:)];
    recognizer.delegate             = self;
    recognizer.numberOfTapsRequired = 2;
    
    [[self view] addGestureRecognizer:recognizer];
}


-(void)createContentsWithSprites:(NSArray *)sprites
{
    
    NSArray *blocks;
    NSArray *balls;
    NSArray *paddles;
    

    for (int i = 0; i <= 2; i++) {
        if (i == 0) {
            blocks  = [sprites objectAtIndex:i];
        }else if (i == 1) {
            balls   = [sprites objectAtIndex:i];
        }else if (i == 2) {
            paddles = [sprites objectAtIndex:i];
        }
    }
    
    [self createPaddle];

    self.isGamePlaying  = NO;
    
    if (balls.count == 0) [self createBall];
    else                  [self createCustomBalls:balls];
    
    
    
    if (blocks.count == 0) [self createBlocks];
    else                   [self createCustomBlocks:blocks];
    
    
    [self startGame];
    
}

-(void)createCustomBlocks:(NSArray *)blocks
{
    for (BlockSprite *block in blocks) {
        
        block.physicsBody.dynamic         = NO;
        block.physicsBody.categoryBitMask = blockCategory;
        //block.zPosition = 1.0;
        [[self childNodeWithName:blockNodeNameSearch] addChild:block];
    }
}

-(void)createCustomBalls:(NSArray *)balls
{
    for (BallSprite *ball in balls) {
        ball.physicsBody.dynamic         = YES;
        ball.physicsBody.categoryBitMask    = ballCategory;
        ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
        ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory | ballCategory;
        
        [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
    }
}

-(void)createBlocks
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



-(void)createBall
{
    BallSprite *ball = [[BallSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/3, self.frame.size.height/3)
                                                currentSize:@"normal"
                                                     status:@"normal"
                                                       name:ballName];
    
    ball.physicsBody.categoryBitMask    = ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory | blockCategory;
    ball.physicsBody.collisionBitMask   = blockCategory | paddleCategory;
    
    [[self childNodeWithName:ballNodeNameSearch] addChild:ball];
}

-(void)createPaddle
{
    PaddleSprite *paddle = [[PaddleSprite alloc] initWithCurrentSize:@"normal"
                                                              status:@"normal"
                                                                name:paddleName];
    
    paddle.physicsBody.categoryBitMask    = paddleCategory;
    paddle.physicsBody.contactTestBitMask = powerUpCategory;
    
    [[self childNodeWithName:paddleNodeNameSearch] addChild:paddle];
    
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
    }
    
}

-(void)createPowerUpWithLocation:(CGPoint)location
{
    PowerUpSprite *powerUpSprite                  = [[PowerUpSprite alloc] initWithLocation:location
                                                                                       type:@"bigBall"
                                                                                       name:@"powerUp"];
    powerUpSprite.physicsBody.categoryBitMask     = powerUpCategory;
    powerUpSprite.physicsBody.collisionBitMask    = paddleCategory | bottomCategory;
    powerUpSprite.physicsBody.contactTestBitMask  = paddleCategory | bottomCategory;
    
    [[self childNodeWithName:contentNodeNameSearch] addChild:powerUpSprite];
}

-(void)startGame
{
    
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
                [timer runAction:runAnimation completion:^{
                    [timer removeFromParent];
                    [[self childNodeWithName:ballNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
                        [node.physicsBody applyImpulse:CGVectorMake(-10.0, 10.0)];
                    }];
                    self.isGamePlaying = YES;
                }];
            }];
        }];
    }];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch        = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node          = [self.physicsWorld bodyAtPoint:touchLocation].node;
    
    if ([node.name isEqualToString: paddleName]) {
        self.isFingerOnPaddle = YES;
    }
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isFingerOnPaddle) {
        UITouch *touch           = [touches anyObject];
        CGPoint touchLocation    = [touch locationInNode:self];
        CGPoint previousLocation = [touch previousLocationInNode:self];
        PaddleSprite *paddle     = (PaddleSprite *)[[self childNodeWithName:paddleNodeNameSearch] childNodeWithName:paddleName];
        int paddleX              = paddle.position.x + (touchLocation.x - previousLocation.x);
        
        paddleX = MAX(paddleX, paddle.size.width/2);
        paddleX = MIN(paddleX, self.size.width - paddle.size.width/2);
        
        paddle.position = CGPointMake(paddleX, paddle.position.y);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isFingerOnPaddle = NO;
    
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
        
        [self.view presentScene:gameOverScene];
    }
    
    if (firstBody.categoryBitMask == bottomCategory && secondBody.categoryBitMask == powerUpCategory) {
        [secondBody.node removeFromParent];
    }
    
    if (firstBody.categoryBitMask == paddleCategory && secondBody.categoryBitMask == powerUpCategory) {
        [secondBody.node removeFromParent];
        
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
    NSLog(@"changed size adjust scene");
    
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
