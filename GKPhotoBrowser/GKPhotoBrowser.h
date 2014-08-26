//
//  GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKPhotoBrowser : UIViewController

@property (nonatomic) UIImage* image;
@property (nonatomic) NSString* text;

+ (instancetype)browser;

- (void)addBrowserToContainerView:(UIView*)containerView;

@end
