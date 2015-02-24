//
//  EditGameScene.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/27/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "EditGameScene.h"
#import "BlockSprite.h"
#import "MainScene.h"
#import "Constants.h"
#import "GameScene.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)


static NSString * const overlayBlockName = @"first";
static NSString * const playButtonName = @"play";


@interface EditGameScene ()

@property (nonatomic) SKNode *nodePressedAtTouchBegins;
@property (nonatomic) BOOL isObjectRotating;
@property (nonatomic) BlockSprite* rotatingBlock;
@property (nonatomic) BOOL isAdjustingSize;
@property (nonatomic) int optionsHeight;

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
        self.anchorPoint                  = CGPointZero;
        self.optionsHeight = 100;
        
        SKSpriteNode *background  = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        background.position       = CGPointZero;
        background.anchorPoint    = CGPointZero;
        background.name           = backgroundName;

        [[self childNodeWithName:backgroundNodeNameSearch] addChild:background];
        
        [self createScene];
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
    longPressRecognizer.minimumPressDuration = 1.0;
    longPressRecognizer.allowableMovement = NO;
    
    
    [[self view] addGestureRecognizer:tapRecognizer];
    [[self view] addGestureRecognizer:longPressRecognizer];
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
    
}


- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    CGPoint reversedPoint = [sender locationInView:[self view]];
    reversedPoint.y       = self.frame.size.height - reversedPoint.y ;
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
}


-(void)createScene
{
    BlockSprite *block = [[BlockSprite alloc] initWithLocation:CGPointMake(self.frame.size.width/4,  -50)
                                                     hitPoints:1
                                                          name:overlayBlockName
                                                    hasPowerup:NO
                                                   currentSize:@"normal"
                                                   canBeEdited:NO];

    [[self childNodeWithName:backgroundNodeNameSearch] addChild:block];
    

    SKLabelNode *play        = [SKLabelNode labelNodeWithFontNamed:@"arial"];
    play.text                = @"play";
    play.name                = playButtonName;
    play.physicsBody         = [SKPhysicsBody bodyWithRectangleOfSize:play.frame.size];
    play.position            = CGPointMake(self.frame.size.width/2, 40);
    play.fontSize            = 20;
    play.physicsBody.dynamic = NO;
    [[self childNodeWithName:overlayNodeNameSearch] addChild:play];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKNode *node = [self.physicsWorld bodyAtPoint:[[touches anyObject] locationInNode:self]].node;
    
    if (![node.name containsString:blockName]) {
        NSLog(@"cannont find block body");
        node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    }
    
    NSLog(@"touch begins pressed %@", node.name);


    self.nodePressedAtTouchBegins = node;
 
    if ([node.name isEqualToString:playButtonName]) [self switchToMainScene];

}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    CGPoint previousLocation  = [touch previousLocationInNode:self];
    SKNode  *nodeAtTouch      = [self.physicsWorld bodyAtPoint:touchLocation].node;
    SKNode *test = [self nodeAtPoint:touchLocation];
    NSLog(@"node %@", test.name);
 
    
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

    if ([self.nodePressedAtTouchBegins.name containsString:@"block"]) {
        
        [self moveBlockWithTouchLocation:touchLocation];
    
    }else if ([self.nodePressedAtTouchBegins.name isEqualToString:@"rotatePoint"]) {
        
        BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
        [block adjustRotationWithTouches:touches];
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:@"editPointTopLeft"]) {
        
        BlockSprite *block = (BlockSprite *)self.nodePressedAtTouchBegins.parent;
        [block adjustSizeWithTouches:touches];
        
    } else if ([self.nodePressedAtTouchBegins.name isEqualToString:backgroundName]){
        
        [self adjustBackgroundWithTouches:touches];
        
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    NSLog(@"end");
    self.nodePressedAtTouchBegins = 0;
    self.isObjectRotating = NO;
    self.isAdjustingSize = NO;
    
}

-(void)adjustBackgroundWithTouches:(NSSet *) touches
{
    NSLog(@"moving background");
    UITouch *touch            = [touches anyObject];
    CGPoint touchLocation     = [touch locationInNode:self];
    CGPoint previousLocation  = [touch previousLocationInNode:self];
    SKNode *background = [self childNodeWithName:backgroundNodeNameSearch];
    float yAdjustment = touchLocation.y - previousLocation.y;
    SKAction *moveBackground = [SKAction moveByX:0 y:yAdjustment duration:0];

    NSLog(@"%f", background.position.y);
    
    if (background.position.y <= 0) {

        if (yAdjustment > 0) {
            // if background is at 0 only allow moving up
            [background runAction:moveBackground];
        }

    } else if (background.position.y >= self.optionsHeight) {
        if (yAdjustment < 0) {
            //if background is above limit only move down
            [background runAction:moveBackground];
        }
    } else if (background.position.y > 0 && background.position.y < self.optionsHeight) {
        [background runAction:moveBackground];
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

-(void)switchToMainScene
{
    NSMutableArray *blocks = [[NSMutableArray alloc] init];
    
    [[self childNodeWithName:blockNodeNameSearch] enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        NSLog(@"block enum %@", node.name);
        BlockSprite *block = (BlockSprite *)node;
        block.isEditable = NO;
        [block updateSelf];
        block.canBeEdited = NO;
        [blocks addObject:block];
        [block removeFromParent];
    }];
    
    MainScene *mainScene = [[MainScene alloc] initWithSize:self.frame.size andBlocks:blocks];
    
    if ([self.view gestureRecognizers]) {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    }
    
    [self removeAllChildren];
    [self.view presentScene:mainScene];
}


-(void)createNodeTree
{
    SKNode *mainNode       = [[SKNode alloc] init];
    SKNode *blockNode      = [[SKNode alloc] init];
    SKNode *ballNode       = [[SKNode alloc] init];
    SKNode *paddleNode     = [[SKNode alloc] init];
    SKNode *contentNode    = [[SKNode alloc] init];
    SKNode *overlayNode    = [[SKNode alloc] init];
    SKNode *backgroundNode = [[SKNode alloc] init];
    
    mainNode.name       = mainNodeName;
    blockNode.name      = blockNodeName;
    ballNode.name       = ballNodeName;
    paddleNode.name     = paddleNodeName;
    overlayNode.name    = overlayNodeName;
    contentNode.name    = contentNodeName;
    backgroundNode.name = backgroundNodeName;
    
    CGPoint origin = CGPointMake(self.frame.origin.x,self.frame.origin.y);
    mainNode.position       = origin;
    blockNode.position      = origin;
    ballNode.position       = origin;
    paddleNode.position     = origin;
    overlayNode.position    = origin;
    contentNode.position    = origin;
    backgroundNode.position = origin;
    
    backgroundNode.zPosition = -1.0;
    overlayNode.zPosition    = 1.0;
    
    
    [contentNode     addChild:blockNode];
    [contentNode     addChild:ballNode];
    [contentNode     addChild:paddleNode];
    [mainNode        addChild:contentNode];
    [mainNode        addChild:overlayNode];
    [mainNode        addChild:backgroundNode];
    [self addChild:mainNode];

}

@end
