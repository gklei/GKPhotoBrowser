//
//  ViewController.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "MainViewController.h"
#import "GKPhotoBrowser.h"

@interface MainViewController () <GKPhotoBrowserDelegate>

@property (weak) IBOutlet UIView* photoBrowserContainer;
@property (weak) IBOutlet UIView* photoBrowserContainer2;
@property (weak) IBOutlet UIView* photoBrowserContainer3;

@property (nonatomic) GKPhotoBrowser* photoBrowser1;
@property (nonatomic) GKPhotoBrowser* photoBrowser2;
@property (nonatomic) GKPhotoBrowser* photoBrowser3;

@property (nonatomic) UITapGestureRecognizer* tapRecognizer1;
@property (nonatomic) UITapGestureRecognizer* tapRecognizer2;
@property (nonatomic) UITapGestureRecognizer* tapRecognizer3;

@end

@implementation MainViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   self.tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePhotoBrowser:)];
   self.tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePhotoBrowser:)];
   self.tapRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePhotoBrowser:)];

   self.photoBrowser1 = [GKPhotoBrowser browser];
   [self.photoBrowser1 addBrowserToContainerView:self.photoBrowserContainer];
   self.photoBrowser1.browserDelegate = self;
   
   self.photoBrowser1.image = [UIImage imageNamed:@"Low in carrige"];
   self.photoBrowser1.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   [self.photoBrowser1.view addGestureRecognizer:self.tapRecognizer1];

   self.photoBrowser2 = [GKPhotoBrowser browser];
   self.photoBrowser2.browserDelegate = self;
   [self.photoBrowser2 addBrowserToContainerView:self.photoBrowserContainer2];

   self.photoBrowser2.image = [UIImage imageNamed:@"Spacer Ring"];
   self.photoBrowser2.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   [self.photoBrowser2.view addGestureRecognizer:self.tapRecognizer2];

   self.photoBrowser3 = [GKPhotoBrowser browser];
   [self.photoBrowser3 addBrowserToContainerView:self.photoBrowserContainer3];
   self.photoBrowser3.browserDelegate = self;

   self.photoBrowser3.image = [UIImage imageNamed:@"Core Extension"];
   self.photoBrowser3.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   [self.photoBrowser3.view addGestureRecognizer:self.tapRecognizer3];
}

#pragma mark - Tap Gesture Recognizer
- (void)togglePhotoBrowser:(UIGestureRecognizer*)recognizer
{
   for (GKPhotoBrowser* browser in @[self.photoBrowser1, self.photoBrowser2, self.photoBrowser3])
   {
      if (browser.view == recognizer.view)
      {
         browser.state = (self.photoBrowser1.state != GKPhotoBrowserStateDisplay) ? GKPhotoBrowserStateDisplay : GKPhotoBrowserStateDefault;
         break;
      }
   }
}

#pragma mark - GKPhotoBrowser Delegate
- (void)gkPhotoBrowserDidZoom:(GKPhotoBrowser *)browser
{
   UITapGestureRecognizer* tapRecognizer = nil;
   if (browser == self.photoBrowser1)
   {
      tapRecognizer = self.tapRecognizer1;
   }
   else if (browser == self.photoBrowser2)
   {
      tapRecognizer = self.tapRecognizer2;
   }
   else if (browser == self.photoBrowser3)
   {
      tapRecognizer = self.tapRecognizer3;
   }
   [browser.view removeGestureRecognizer:tapRecognizer];
}

- (void)gkPhotoBrowserDidDismiss:(GKPhotoBrowser *)browser
{
   UITapGestureRecognizer* tapRecognizer = nil;
   if (browser == self.photoBrowser1)
   {
      tapRecognizer = self.tapRecognizer1;
   }
   else if (browser == self.photoBrowser2)
   {
      tapRecognizer = self.tapRecognizer2;
   }
   else if (browser == self.photoBrowser3)
   {
      tapRecognizer = self.tapRecognizer3;
   }
   [browser.view addGestureRecognizer:tapRecognizer];
}

@end
