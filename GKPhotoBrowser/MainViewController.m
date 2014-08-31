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
@property (weak) IBOutlet UIView* photoBrowserContainer2;
@property (nonatomic) GKPhotoBrowser* photoBrowser1;
@property (nonatomic) GKPhotoBrowser* photoBrowser2;

@property (weak) IBOutlet NSLayoutConstraint* heightConstraint;
@property (weak) IBOutlet NSLayoutConstraint* widthConstraint;

@property (nonatomic) BOOL enlarged;

@end

@implementation MainViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.photoBrowser1 = [GKPhotoBrowser browser];
   [self.photoBrowser1 addBrowserToContainerView:self.photoBrowserContainer];
   
   self.photoBrowser1.image = [UIImage imageNamed:@"Low in carrige"];
   self.photoBrowser1.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   
   [self addChildViewController:self.photoBrowser1];
   [self.photoBrowser1 didMoveToParentViewController:self];

//   self.photoBrowser2 = [GKPhotoBrowser browser];
//   [self.photoBrowser2 addBrowserToContainerView:self.photoBrowserContainer2];
//
//   self.photoBrowser2.image = [UIImage imageNamed:@"Spacer Ring"];
//   self.photoBrowser2.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
//
//   [self addChildViewController:self.photoBrowser2];
//   [self.photoBrowser2 didMoveToParentViewController:self];
}

@end
