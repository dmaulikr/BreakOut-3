//
//  GamePiece.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GamePiece : SKSpriteNode

-(void)updateSizeWithImageNamed:(NSString *)imageName currentSize:(NSString *)currentSize;


@end
