//
//  GKPhotoBrowser.h
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKPhotoBrowserState)
{
   GKPhotoBrowserStateDefault,
   GKPhotoBrowserStateDisplay,
};

@class GKPhotoBrowser;
@protocol GKPhotoBrowserDelegate <NSObject>
- (void)gkPhotoBrowserDidZoom:(GKPhotoBrowser*)broswer;
- (void)gkPhotoBrowserDidDismiss:(GKPhotoBrowser*)browser;
@end

@interface GKPhotoBrowser : UIViewController

@property (nonatomic) UIImage* image;
@property (nonatomic) NSString* text;
@property (nonatomic) BOOL respectImageAspectRatio;
@property (nonatomic) GKPhotoBrowserState state;
@property (weak) NSObject<GKPhotoBrowserDelegate>* browserDelegate;

+ (instancetype)browser;
- (void)addBrowserToContainerView:(UIView*)containerView;

@end
