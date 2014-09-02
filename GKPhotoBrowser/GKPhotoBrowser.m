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
@property (nonatomic) UITextView* textView;
@property (nonatomic) CALayer* dimLayer;
@property (nonatomic, readonly) CGPoint containerViewCenterInSuperview;
@property (nonatomic) UIView* topMostSuperview;
@property (nonatomic) FlatPillButton* doneButton;

@end

@implementation GKPhotoBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
   {
      self.state = GKPhotoBrowserStateDefault;
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
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
   self.textView.backgroundColor = [UIColor clearColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = NO;
   self.textView.editable = NO;
   self.textView.selectable = NO;

   [self.containerView.superview addSubview:self.textView];
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
   self.dimLayer.opacity = .9;
}

- (void)setupDoneButton
{
   self.doneButton = [FlatPillButton button];
   [self.doneButton addTarget:self
              action:@selector(dismissBrowser:)
    forControlEvents:UIControlEventTouchUpInside];

   self.doneButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 55, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 5, 50.0, 20.0);

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12];
   NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:@"Done" attributes:@{NSFontAttributeName : font,
                                                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]}];
   [self.doneButton setAttributedTitle:attrString forState:UIControlStateNormal];
   [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Property Overrides
- (void)setImage:(UIImage *)image
{
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
      [self toggleResizeWithState:self.state];
   }
}

#pragma mark - Public
- (void)addBrowserToContainerView:(UIView *)containerView
{
   self.containerView = containerView;
   [self.containerView addSubview:self.view];

   UIView* view = self.view;
   NSDictionary* views = NSDictionaryOfVariableBindings(view);
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];

   [self setupDoneButton];
}

#pragma mark - Private
- (void)dismissBrowser:(UIButton*)sender
{
   self.state = GKPhotoBrowserStateDefault;
}

- (void)toggleState
{
   _state = (_state == GKPhotoBrowserStateDefault) ? GKPhotoBrowserStateDisplay: GKPhotoBrowserStateDefault;
}

- (void)toggleResizeWithState:(GKPhotoBrowserState)state
{
   [[UIApplication sharedApplication] setStatusBarStyle: (state != GKPhotoBrowserStateDisplay) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];

   if (state == GKPhotoBrowserStateDisplay)
   {
      [self.topMostSuperview addSubview:self.doneButton];
   }
   else
   {
      [self.doneButton removeFromSuperview];
   }
   
   [self.containerView.superview bringSubviewToFront:self.containerView];
   [self.containerView.superview layoutIfNeeded];
   self.textView.layer.zPosition = 100;

   self.dimLayer.actions = @{@"frame" : [NSNull null], @"bounds" : [NSNull null], @"position" : [NSNull null]};
   self.dimLayer.backgroundColor = (state == GKPhotoBrowserStateDisplay) ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
   if (state == GKPhotoBrowserStateDisplay)
   {
      [self.containerView.superview.layer insertSublayer:self.dimLayer below:self.containerView.layer];

      CGRect dimLayerFrame = self.dimLayer.frame;
      CGRect convertedFrame = [self.topMostSuperview.layer convertRect:dimLayerFrame fromLayer:self.containerView.superview.layer];

      self.dimLayer.frame = CGRectMake(0, -CGRectGetMinY(convertedFrame), CGRectGetWidth(dimLayerFrame), CGRectGetHeight(dimLayerFrame));
   }
   else
   {
      [self.dimLayer removeFromSuperlayer];
      self.dimLayer.frame = [UIScreen mainScreen].bounds;
   }

   CGFloat containerViewSuperviewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewSuperviewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat scale = containerViewSuperviewWidth / CGRectGetWidth(self.containerView.frame);

   CGFloat containerViewTargetHeight = CGRectGetHeight(self.containerView.frame) * scale;
   CGFloat textViewHeight = containerViewSuperviewHeight - containerViewTargetHeight - statusBarHeight;
   CGPoint screenCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));

   CGFloat verticalOffset = (containerViewSuperviewHeight - containerViewTargetHeight)*.5;
   CGFloat verticalShift = self.containerViewCenterInSuperview.y - screenCenter.y + verticalOffset - statusBarHeight - 35;
   CGFloat horizontalShift = self.containerViewCenterInSuperview.x - screenCenter.x;

   CATransform3D transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   self.textView.frame = CGRectMake(0,
                                    containerViewSuperviewHeight,
                                    containerViewSuperviewWidth,
                                    textViewHeight);

   [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

      self.containerView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(transform, scale, scale, 1) : CATransform3DIdentity;
      self.textView.hidden = (state != GKPhotoBrowserStateDisplay);

   } completion:^(BOOL finished){

      if (state == GKPhotoBrowserStateDisplay)
      {
         [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

            CGRect containerFrameInTopMostSuperview = [self.topMostSuperview convertRect:self.containerView.superview.frame toView:self.topMostSuperview];
            self.textView.frame = CGRectMake(0,
                                             containerViewSuperviewHeight - textViewHeight - CGRectGetMinY(containerFrameInTopMostSuperview) + 35,
                                             containerViewSuperviewWidth,
                                             textViewHeight);
         } completion:^(BOOL finished){

            [self.browserDelegate gkPhotoBrowserDidZoom:self];
         }];
      }
      else
      {
         [self.containerView.superview sendSubviewToBack:self.containerView];
         [self.containerView.superview layoutIfNeeded];
         [self.browserDelegate gkPhotoBrowserDidDismiss:self];
      }
   }];
}

@end
