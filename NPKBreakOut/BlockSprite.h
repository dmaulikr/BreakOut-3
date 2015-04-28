//
//  BlockSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"
#import <UIKit/UIKit.h>

@interface BlockSprite : GamePiece <NSCoding>

@property (nonatomic) int hitPoints;
@property (nonatomic) NSString *powerUpType;
@property (nonatomic) NSString *currentSize;
@property (nonatomic) BOOL canBeEdited;
@property (nonatomic) BOOL isRotatable;
@property (nonatomic) BOOL hitPointsCanBeChanged;
@property (nonatomic) BOOL showPowerUp;
@property (nonatomic) NSString *powerUpName;


-(void)updateSelf;
-(SKSpriteNode *)initWithLocation:(CGPoint)   location
                        hitPoints:(int)       hitPoints
                             name:(NSString *)name
                   hasPowerupType:(NSString *)      hasPowerupType
                      currentSize:(NSString *)currentSize
                      canBeEdited:(BOOL)       canBeEdited;
-(void)adjustSizeWithTouches:(NSSet *)touches;
-(void)adjustRotationWithTouches:(NSSet *)touches;
-(void)addHitPoint;


@end
