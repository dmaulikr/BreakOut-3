//
//  Constants.m
//  NPKBreakOut
//
//  Created by Nathan Knable on 2/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)


NSString * const blockName          = @"block";
NSString * const ballName           = @"ball";
NSString * const paddleName         = @"paddle";
NSString * const powerUpName        = @"powerUp";
NSString * const pauseButtonName    = @"pauseButton";
NSString * const backgroundName     = @"background";
NSString * const bottomOptionsName  = @"bottomOptions";
NSString * const rightOptionsName   = @"rightOptions";
NSString * const rotateButtonName   = @"rotateButton";
NSString * const rotatePointName    = @"rotatePoint";
NSString * const hitPointsButtonName= @"hitPointButton";
NSString * const hitPointsLabelName = @"hitPointLabel";
NSString * const gridButtonName     = @"gridButton";
NSString * const powerUpButtonName    = @"powerButton";
NSString * const powerUpBigBall     = @"powerUPBigBall";
NSString * const powerUpDoubleBall  = @"powerUpDoubleBall";


NSString * const orientationHorizontal = @"horizontal";
NSString * const orientationVertical = @"vertical";

uint32_t const ballCategory     = 0x1 << 0;
uint32_t const blockCategory    = 0x1 << 2;
uint32_t const paddleCategory   = 0x1 << 3;
uint32_t const bottomCategory   = 0x1 << 1;
uint32_t const powerUpCategory  = 0x1 << 4;
uint32_t const borderCategory   = 0x1 << 5;


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
NSString * const blockNodeName      = @"sqaureNode";
NSString * const ballNodeName       = @"circleNode";
NSString * const paddleNodeName     = @"greyNode";
NSString * const powerUpNodeName    = @"strongNode";
NSString * const optionsNodeName    = @"optionsNode";

NSString * const mainNodeNameSearch       = @"//mainNode";
NSString * const overlayNodeNameSearch    = @"//overlayNode";
NSString * const backgroundNodeNameSearch = @"//backgroundNode";
NSString * const contentNodeNameSearch    = @"//contentNode";
NSString * const blockNodeNameSearch      = @"//sqaureNode";
NSString * const ballNodeNameSearch       = @"//circleNode";
NSString * const paddleNodeNameSearch     = @"//greyNode";
NSString * const powerUpNodeNameSearch    = @"//strongNode";
NSString * const optionsNodeNameSearch    = @"//optionsNode";

