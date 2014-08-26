//
//  GKPaddedLabel.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKPaddedLabel.h"

@implementation GKPaddedLabel

- (void)drawTextInRect:(CGRect)rect
{
   UIEdgeInsets insets = {0, 4, 0, 4};
   return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
