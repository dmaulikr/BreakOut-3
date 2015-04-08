//
//  Constants.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 2/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const blockName         = @"block";
NSString * const ballName          = @"ball";
NSString * const paddleName        = @"paddle";
NSString * const powerUpName       = @"powerUp";
NSString * const backgroundName    = @"background";
NSString * const bottomOptionsName = @"bottomOptions";
NSString * const rightOptionsName  = @"rightOptions";

uint32_t const ballCategory     = 0x1 << 0;
uint32_t const blockCategory    = 0x1 << 2;
uint32_t const paddleCategory   = 0x1 << 3;
uint32_t const bottomCategory   = 0x1 << 1;
uint32_t const powerUpCategory  = 0x1 << 4;


NSString * const gameTitleName = @"gameTitle";
NSString * const playLabelName = @"play";
NSString * const editLabelName = @"edit";
NSString * const loadLabelName = @"load";
NSString * const backLabelName = @"back";
NSString * const editSavesName = @"editSaves";

NSString * const saveFileDirectory = @"gameData";

NSString * const mainNodeName       = @"mainNode";
NSString * const overlayNodeName    = @"overlayNode";
NSString * const backgroundNodeName = @"backgroundNode";
NSString * const contentNodeName    = @"contentNode";
NSString * const blockNodeName      = @"blockNode";
NSString * const ballNodeName       = @"ballNode";
NSString * const paddleNodeName     = @"paddleNode";
NSString * const powerUpNodeName    = @"powerUpNode";
NSString * const optionsNodeName    = @"optionsNode";

NSString * const mainNodeNameSearch       = @"//mainNode";
NSString * const overlayNodeNameSearch    = @"//overlayNode";
NSString * const backgroundNodeNameSearch = @"//backgroundNode";
NSString * const contentNodeNameSearch    = @"//contentNode";
NSString * const blockNodeNameSearch      = @"//blockNode";
NSString * const ballNodeNameSearch       = @"//ballNode";
NSString * const paddleNodeNameSearch     = @"//paddleNode";
NSString * const powerUpNodeNameSearch    = @"//powerUpNode";
NSString * const optionsNodeNameSearch    = @"//optionsNode";