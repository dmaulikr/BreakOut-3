//
//  PowerUpSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"

@interface PowerUpSprite : GamePiece

@property (nonatomic) NSString *type;

-(PowerUpSprite *)initWithLocation:(CGPoint)location type:(NSString *)type name:(NSString *)name;

@end
