//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKPhotoBrowser.h"

@interface GKPhotoBrowser ()

@property (weak) IBOutlet UIImageView* imageView;

@property (nonatomic) UIView* containerView;
@property (nonatomic) UITextView* textView;
@property (nonatomic) CALayer* dimLayer;
@property (nonatomic) BOOL zoomed;
@property (nonatomic, readonly) CGPoint containerViewCenterInSuperview;
@property (nonatomic) UIView* topMostSuperview;

@end

@implementation GKPhotoBrowser

#pragma mark - Class Init
+ (instancetype)browser
{
   return [[super alloc] initWithNibName:nil bundle:nil];
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

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.view.translatesAutoresizingMaskIntoConstraints = NO;
   
   UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleResize:)];
   [self.view addGestureRecognizer:tapRecognizer];
   
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

#pragma mark - Public
- (void)addBrowserToContainerView:(UIView *)containerView
{
   self.containerView = containerView;
   [self.containerView addSubview:self.view];

   UIView* view = self.view;
   NSDictionary* views = NSDictionaryOfVariableBindings(view);
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
}

#pragma mark - Private
- (void)toggleResize:(UITapGestureRecognizer*)recognizer
{
   self.zoomed = !self.zoomed;

   [self.containerView.superview bringSubviewToFront:self.containerView];
   [self.containerView.superview layoutIfNeeded];
   self.textView.layer.zPosition = 100;

   self.dimLayer.backgroundColor = self.zoomed ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
   if (self.zoomed)
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
   CGFloat verticalShift = self.containerViewCenterInSuperview.y - screenCenter.y + verticalOffset - statusBarHeight;
   CGFloat horizontalShift = self.containerViewCenterInSuperview.x - screenCenter.x;

   CATransform3D transform = self.zoomed ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   self.textView.frame = CGRectMake(0,
                                    containerViewSuperviewHeight,
                                    containerViewSuperviewWidth,
                                    textViewHeight);

   [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

      self.containerView.layer.transform = self.zoomed ? CATransform3DScale(transform, scale, scale, 1) : CATransform3DIdentity;
      self.textView.hidden = !self.zoomed;

   } completion:^(BOOL finished){

      if (self.zoomed)
      {
         [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

            CGRect containerFrameInTopMostSuperview = [self.topMostSuperview convertRect:self.containerView.superview.frame toView:self.topMostSuperview];
            self.textView.frame = CGRectMake(0,
                                             containerViewSuperviewHeight - textViewHeight - CGRectGetMinY(containerFrameInTopMostSuperview),
                                             containerViewSuperviewWidth,
                                             textViewHeight);
         } completion:nil];
      }
      else
      {
         [self.containerView.superview sendSubviewToBack:self.containerView];
         [self.containerView.superview layoutIfNeeded];
      }
   }];
}

- (void)repositionTextViewBeforeAnimationWithHeight:(CGFloat)textViewHeight
{
   CGFloat containerViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
   self.textView.frame = CGRectMake(0, containerViewHeight, containerViewWidth, textViewHeight);
}

@end
