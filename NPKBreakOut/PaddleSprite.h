//
//  PaddleSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"

@interface PaddleSprite : GamePiece <NSCoding>

@property (nonatomic) NSString *currentSize;
@property (nonatomic) NSString *status;
@property (nonatomic) BOOL isRotatable;
@property (nonatomic) NSString *orientation;
@property (nonatomic) BOOL isMoving;

-(PaddleSprite *)initWithCurrentSize:(NSString *)currentSize position:(CGPoint)position status:(NSString *)status name:(NSString *)name;
-(void)adjustRotation;


@end
