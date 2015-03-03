//
//  PaddleSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"

@interface PaddleSprite : GamePiece

@property (nonatomic) NSString *currentSize;
@property (nonatomic) NSString *status;

-(PaddleSprite *)initWithCurrentSize:(NSString *)currentSize position:(CGPoint)position status:(NSString *)status name:(NSString *)name;
-(void)updateSelf;


@end
