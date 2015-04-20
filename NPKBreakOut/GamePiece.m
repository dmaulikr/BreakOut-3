//
//  GamePiece.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 1/21/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import "GamePiece.h"

@implementation GamePiece

-(void)updateSizeWithImageNamed:(NSString *)imageName currentSize:(NSString *)currentSize
{
    
    int testWidth = [SKSpriteNode spriteNodeWithImageNamed:imageName].size.width;
    int selfWidth = self.frame.size.width;
    BOOL isSizeNormal = [currentSize isEqualToString:@"normal"];
    BOOL isSizeSmall = [currentSize isEqualToString:@"small"];
    BOOL isSizeBig = [currentSize isEqualToString:@"big"];
    
    
    if (isSizeNormal) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ correct size", self.name);
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@too small", self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ too big", self.name);
        }
    }
    
    if (isSizeSmall) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ one too big", self.name);
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@ correct size",self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ two too big",self.name);
        }
    }
    
    if (isSizeBig) {
        if (selfWidth == testWidth) {
            //NSLog(@"%@ one too small growing!!", self.name);
            SKAction *grow = [SKAction scaleBy:2 duration:1];
            SKAction *wait = [SKAction waitForDuration:15];
            SKAction *shrink = [SKAction scaleBy:0.5 duration:1];
            SKAction *growWaitShrink = [SKAction sequence:@[grow, wait, shrink]];
            [self runAction:growWaitShrink];
        } else if (selfWidth < testWidth) {
            //NSLog(@"%@ two too small",self.name);
        } else if (selfWidth > testWidth) {
            //NSLog(@"%@ correct size",self.name);
        }
        
    }
    
}

@end
