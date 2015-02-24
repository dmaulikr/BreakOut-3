//
//  BlockSprite.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"
#import <UIKit/UIKit.h>

@interface BlockSprite : GamePiece

@property (nonatomic) int hitPoints;
@property (nonatomic) BOOL hasPowerup;
@property (nonatomic) NSString *currentSize;
@property (nonatomic) BOOL isEditable;
@property (nonatomic) BOOL canBeEdited;


-(void)updateSelf;
-(SKSpriteNode *)initWithLocation:(CGPoint)location
                        hitPoints:(int)hitPoints name:(NSString *)name
                       hasPowerup:(BOOL)hasPowerup currentSize:(NSString *)currentSize
                      canBeEdited:(BOOL)canBeEdited;
-(void)makeSelfEditable;
-(void)makeSelfUneditable;
-(SKShapeNode *)createRotatePoint;
-(SKShapeNode *)createEditPointTopLeft;
-(void)adjustSizeWithTouches:(NSSet *)touches;
-(void)adjustRotationWithTouches:(NSSet *)touches;


@end
