//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKPhotoBrowser.h"
#import "FlatPillButton.h"

@interface GKPhotoBrowser () <UIGestureRecognizerDelegate>

@property (weak) IBOutlet UIImageView* imageView;

@property (nonatomic) UIView* containerView;
@property (nonatomic) UIView* topMostSuperview;
@property (nonatomic) UITextView* textView;

@property (nonatomic) UIView* containerZoomView;
@property (nonatomic) UIViewController* parentController;

@property (nonatomic) CALayer* dimLayer;
@property (nonatomic) FlatPillButton* doneButton;
@property (nonatomic, readonly) CGPoint containerViewCenterInSuperview;

@property (nonatomic) UITapGestureRecognizer* tapRecognizer;

@end

@implementation GKPhotoBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
   {
      self.state = GKPhotoBrowserStateDefault;
      self.hidesParentNavigationBarsOnZoom = YES;
      self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
   }
   return self;
}

#pragma mark - Class Init
+ (instancetype)browser
{
   return [[super alloc] initWithNibName:nil bundle:nil];
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   self.view.translatesAutoresizingMaskIntoConstraints = NO;

   [self setupTextView];
   [self setupDimLayer];
}

#pragma mark - Setup
- (void)setupTextView
{
   self.textView = [[UITextView alloc] init];
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
   self.textView.backgroundColor = [UIColor clearColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = NO;
   self.textView.editable = NO;
   self.textView.selectable = NO;
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
   self.dimLayer.opacity = .9;
   self.dimLayer.actions = @{@"frame" : [NSNull null], @"bounds" : [NSNull null], @"position" : [NSNull null]};
}

- (void)setupDoneButton
{
   self.doneButton = [FlatPillButton button];
   [self.doneButton addTarget:self action:@selector(dismissBrowser:) forControlEvents:UIControlEventTouchUpInside];

   CGSize doneButtonSize = {60, 30};
   CGFloat padding = 5;
   self.doneButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - doneButtonSize.width - padding,
                                      CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + padding,
                                      60.0,
                                      30.0);

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
   NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSFontAttributeName : font,
                                                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]}];
   [self.doneButton setAttributedTitle:attrString forState:UIControlStateNormal];
   [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Property Overrides
- (void)setImage:(UIImage *)image
{
   self.containerZoomView.layer.contents = (__bridge id)image.CGImage;
   [self.imageView setImage:image];
}

- (void)setText:(NSString *)text
{
   self.textView.text = text;
}

- (CGPoint)containerViewCenterInSuperview
{
   return [self.topMostSuperview convertPoint:self.containerView.center fromView:self.containerView.superview];
}

- (UIView*)topMostSuperview
{
   UIView* superview = self.view.superview;
   while (true)
   {
      if (superview.superview == nil)
      {
         return superview;
      }
      superview = superview.superview;
   }
}

- (void)setState:(GKPhotoBrowserState)state
{
   if (_state != state)
   {
      [self toggleState];
      [self updateParentNavigationBarsForState:self.state];
      [self toggleResizeWithState:self.state];
   }
}

- (void)setUsesTapRecognizerForDisplay:(BOOL)usesTapRecognizerForDisplay
{
   if (_usesTapRecognizerForDisplay != usesTapRecognizerForDisplay)
   {
      if (usesTapRecognizerForDisplay)
      {
         [self.view addGestureRecognizer:self.tapRecognizer];
      }
      else
      {
         [self.view removeGestureRecognizer:self.tapRecognizer];
      }
   }
}

#pragma mark - Private
- (void)zoom:(UIGestureRecognizer*)recognizer
{
   self.state = GKPhotoBrowserStateDisplay;
}

- (void)dismissBrowser:(UIButton*)sender
{
   self.state = GKPhotoBrowserStateDefault;
}

- (void)toggleState
{
   _state = (_state == GKPhotoBrowserStateDefault) ? GKPhotoBrowserStateDisplay: GKPhotoBrowserStateDefault;
}

- (void)updateParentNavigationBarsForState:(GKPhotoBrowserState)state
{
   if (self.hidesParentNavigationBarsOnZoom)
   {
      BOOL hidden = state == GKPhotoBrowserStateDisplay;
      [self setParentNavigationBarsHidden:hidden];
   }
}

- (void)updateDoneButtonWithState:(GKPhotoBrowserState)state
{
   if (state == GKPhotoBrowserStateDisplay)
   {
      [self.topMostSuperview addSubview:self.doneButton];
   }
   else
   {
      [self.doneButton removeFromSuperview];
   }
}

- (void)updateDimLayerWithState:(GKPhotoBrowserState)state
{
   if (state == GKPhotoBrowserStateDisplay)
   {
      self.dimLayer.backgroundColor = [UIColor blackColor].CGColor;
      [self.topMostSuperview.layer addSublayer:self.dimLayer];
   }
   else
   {
      [self.dimLayer removeFromSuperlayer];
      self.dimLayer.backgroundColor = [UIColor clearColor].CGColor;
   }
}

- (void)toggleResizeWithState:(GKPhotoBrowserState)state
{
   [[UIApplication sharedApplication] setStatusBarStyle: (state != GKPhotoBrowserStateDisplay) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];

   if (self.textView.superview == nil)
   {
      [self.topMostSuperview addSubview:self.textView];
   }

   [self updateDimLayerWithState:state];
   [self updateDoneButtonWithState:state];

   if (self.containerZoomView.superview == nil)
   {
      self.containerZoomView.frame = [self.containerView.superview convertRect:self.containerView.frame toView:self.topMostSuperview];
      [self.topMostSuperview addSubview:self.containerZoomView];
      self.containerView.hidden = YES;
   }

   CGFloat containerViewSuperviewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewSuperviewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat xScale = containerViewSuperviewWidth / CGRectGetWidth(self.containerView.frame);

   CGFloat containerViewTargetHeight;
   CGFloat yScale = xScale;
   if (self.respectsImageAspectRatio)
   {
      containerViewTargetHeight = self.imageView.image.size.height * (containerViewSuperviewWidth / self.imageView.image.size.width);
      yScale = containerViewTargetHeight / CGRectGetHeight(self.containerView.frame);
   }
   else
   {
      containerViewTargetHeight = CGRectGetHeight(self.containerView.frame) * xScale;
   }
   CGFloat textViewHeight = containerViewSuperviewHeight - containerViewTargetHeight - statusBarHeight;

   self.textView.frame = CGRectMake(0, containerViewSuperviewHeight, containerViewSuperviewWidth, textViewHeight);
   self.textView.layer.zPosition = 100;

   CGPoint screenCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
   CGFloat verticalOffset = (containerViewSuperviewHeight - containerViewTargetHeight)*.5;
   CGFloat verticalShift = self.containerViewCenterInSuperview.y - screenCenter.y + verticalOffset - statusBarHeight - CGRectGetHeight(self.doneButton.frame) - 10;
   CGFloat horizontalShift = self.containerViewCenterInSuperview.x - screenCenter.x;

   CATransform3D transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   void (^zoomAnimation)() = ^
   {
      self.containerZoomView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(transform, xScale, yScale, 1) : CATransform3DIdentity;
      self.textView.hidden = (state != GKPhotoBrowserStateDisplay);
   };

   void (^textViewAnimation)() = ^
   {
      CGRect containerFrameInTopMostSuperview = [self.topMostSuperview convertRect:self.textView.superview.frame toView:self.topMostSuperview];
      CGFloat doneButtonVerticalPadding = CGRectGetHeight(self.doneButton.frame) + 10;
      self.textView.frame = CGRectMake(0,
                                       containerViewSuperviewHeight - textViewHeight - CGRectGetMinY(containerFrameInTopMostSuperview) + doneButtonVerticalPadding,
                                       containerViewSuperviewWidth,
                                       textViewHeight - doneButtonVerticalPadding - 10);
   };

   void (^textViewAnimationCompletion)(BOOL finished) = ^(BOOL finished)
   {
      [self.browserDelegate gkPhotoBrowserDidZoom:self];
   };

   void (^zoomAnimationCompletion)(BOOL) = ^(BOOL finished)
   {
      if (state == GKPhotoBrowserStateDisplay)
      {
         [UIView animateWithDuration:.15
                               delay:0
                             options:UIViewAnimationOptionCurveEaseOut
                          animations:textViewAnimation
                          completion:textViewAnimationCompletion];
      }
      else
      {
         self.containerView.hidden = NO;
         [self.containerZoomView removeFromSuperview];
         [self.browserDelegate gkPhotoBrowserDidDismiss:self];
      }
   };

   [UIView animateWithDuration:.25
                         delay:0
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:zoomAnimation
                    completion:zoomAnimationCompletion];
}

- (void)setParentNavigationBarsHidden:(BOOL)hidden
{
   UIViewController* parentViewController = self.parentController;
   while (parentViewController != nil)
   {
      parentViewController.navigationController.navigationBarHidden = hidden;
      parentViewController = parentViewController.parentViewController;
   }
}

#pragma mark - Public
- (void)addBrowserToContainerView:(UIView *)containerView inParentController:(UIViewController*)parentController
{
   self.containerView = containerView;
   [self.containerView addSubview:self.view];

   UIView* view = self.view;
   NSDictionary* views = NSDictionaryOfVariableBindings(view);
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];

   [self setupDoneButton];

   self.containerZoomView = [[UIView alloc] initWithFrame:self.containerView.frame];
}

@end
