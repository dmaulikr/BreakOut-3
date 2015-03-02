//
//  BallSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"

@interface BallSprite : GamePiece

@property (nonatomic) NSString *currentSize;
@property (nonatomic) NSString *status;
@property (nonatomic) CGVector *direction;

-(BallSprite*)initWithLocation:(CGPoint)location currentSize:(NSString*)currentSize status:(NSString*)status name:(NSString*)name;
-(instancetype)initWithSize:(CGSize)size Blocks:(NSArray*)blocks Balls:(NSArray*)balls AndPaddles:(NSArray*)paddles;

-(void)updateSelf;

@end
