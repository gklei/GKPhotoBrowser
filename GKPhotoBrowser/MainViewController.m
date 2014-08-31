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
@property (weak) IBOutlet UIView* photoBrowserContainer3;
@property (nonatomic) GKPhotoBrowser* photoBrowser1;
@property (nonatomic) GKPhotoBrowser* photoBrowser2;
@property (nonatomic) GKPhotoBrowser* photoBrowser3;

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
//   self.photoBrowser1.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   self.photoBrowser1.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";

   self.photoBrowser2 = [GKPhotoBrowser browser];
   [self.photoBrowser2 addBrowserToContainerView:self.photoBrowserContainer2];

   self.photoBrowser2.image = [UIImage imageNamed:@"Spacer Ring"];
//   self.photoBrowser2.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   self.photoBrowser2.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";


   self.photoBrowser3 = [GKPhotoBrowser browser];
   [self.photoBrowser3 addBrowserToContainerView:self.photoBrowserContainer3];

   self.photoBrowser3.image = [UIImage imageNamed:@"Core Extension"];
   //   self.photoBrowser3.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
   self.photoBrowser3.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";

}

@end
