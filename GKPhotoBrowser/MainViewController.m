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

@property (nonatomic) NSArray* browsers;

@end

@implementation MainViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];

   self.photoBrowser1 = [GKPhotoBrowser browser];
   [self.photoBrowser1 addBrowserToContainerView:self.photoBrowserContainer inParentController:self];
   self.photoBrowser1.browserDelegate = self;
   self.photoBrowser1.headerText = @"Barber Polling";
   
   self.photoBrowser1.image = [UIImage imageNamed:@"(3) Low In Carrige"];
   self.photoBrowser1.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   self.photoBrowser1.usesTapRecognizerForDisplay = YES;
   self.photoBrowser1.respectsImageAspectRatio = YES;

   self.photoBrowser2 = [GKPhotoBrowser browser];
   self.photoBrowser2.browserDelegate = self;
   [self.photoBrowser2 addBrowserToContainerView:self.photoBrowserContainer2 inParentController:self];

   self.photoBrowser2.image = [UIImage imageNamed:@"(7) Spacer Ring"];
   self.photoBrowser2.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling. Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   self.photoBrowser2.usesTapRecognizerForDisplay = YES;
   self.photoBrowser2.respectsImageAspectRatio = YES;
   self.photoBrowser2.headerText = @"Low Cling";

   self.photoBrowser3 = [GKPhotoBrowser browser];
   [self.photoBrowser3 addBrowserToContainerView:self.photoBrowserContainer3 inParentController:self];
   self.photoBrowser3.browserDelegate = self;

   self.photoBrowser3.image = [UIImage imageNamed:@"(14) Gauge Band"];
//   self.photoBrowser3.text = @"Holes can form as a result of damage on the roll surface.  Abrasions, dings, & cuts can usually be removed by pulling film off the roll until the affected area has been removed.  The source of this type of damage is usually a result of transit damage, or rough handling.";
   self.photoBrowser3.usesTapRecognizerForDisplay = YES;
   self.photoBrowser3.respectsImageAspectRatio = YES;
   self.photoBrowser3.headerText = @"Diagonal Holes";
   [self.photoBrowser3 makeCaptionSubstring:@"damage on the roll surface" hyperlinkToDisplayImage:[UIImage imageNamed:@"(1) Damaged Rollers"]];

   self.browsers = @[self.photoBrowser1, self.photoBrowser2, self.photoBrowser3];
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
- (void)gkPhotoBrowserWillZoom:(GKPhotoBrowser *)browser
{
}

- (void)gkPHotoBrowserWillDismiss:(GKPhotoBrowser *)broswer
{
}

- (void)gkPhotoBrowserDidZoom:(GKPhotoBrowser *)browser
{
   for (GKPhotoBrowser* b in self.browsers)
   {
      if (b != browser)
      {
         browser.usesTapRecognizerForDisplay = NO;
      }
   }
}

- (void)gkPhotoBrowserDidDismiss:(GKPhotoBrowser *)browser
{
   for (GKPhotoBrowser* b in self.browsers)
   {
      b.usesTapRecognizerForDisplay = YES;
   }
}

@end
