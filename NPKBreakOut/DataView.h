//
//  DataView.h
//  NPKBreakOut
//
//  Created by Nathan Knable on 3/23/15.
//  Copyright (c) 2015 Nathan Knable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataView : UIView <UITextFieldDelegate>


-(instancetype)initWithFrame:(CGRect)frame fileName:(NSString *)fileName;

@end
