//
//  ViewController.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "MainViewController.h"
#import "GKPhotoBrowser.h"

@interface MainViewController ()

@property (weak) IBOutlet UIView* photoBrowserContainer;
@property (nonatomic) GKPhotoBrowser* photoBrowser;

@property (weak) IBOutlet NSLayoutConstraint* heightConstraint;
@property (weak) IBOutlet NSLayoutConstraint* widthConstraint;

@property (nonatomic) BOOL enlarged;

@end

@implementation MainViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.photoBrowser = [GKPhotoBrowser browser];
   [self.photoBrowser addBrowserToContainerView:self.photoBrowserContainer];
   
   self.photoBrowser.image = [UIImage imageNamed:@"Core Extension"];
   self.photoBrowser.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   
   [self addChildViewController:self.photoBrowser];
   [self.photoBrowser didMoveToParentViewController:self];
}

@end
