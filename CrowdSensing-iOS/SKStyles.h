//
//  SKStyles.h
//  SensingKit-iOS
//
//  Created by Kleomenis Katevas on 23/11/2015.
//  Copyright (c) 2015 Queen Mary University of London. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SKStyles : NSObject

// Colors
+ (UIColor*)backgroundColor;

// Drawing Methods
+ (void)drawRoundButtonFilledWithTitle: (NSString*)title;
+ (void)drawRoundButtonStrokedWithTitle: (NSString*)title;
+ (void)drawRoundButtonStrokedDeactivatedWithTitle: (NSString*)title;
+ (void)drawRoundButtonFilledDeactivatedWithTitle: (NSString*)title;

@end
