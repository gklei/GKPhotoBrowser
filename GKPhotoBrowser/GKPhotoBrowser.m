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
@property (nonatomic) BOOL enlarged;

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

#pragma mark - Lifecycle
- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.view.translatesAutoresizingMaskIntoConstraints = NO;
   
   UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleResize:)];
   [self.view addGestureRecognizer:tapRecognizer];
   
   [self setupTextView];
}

- (void)viewDidLayoutSubviews
{
   if (!self.dimLayer)
   {
      [self setupDimLayerWithContainerView:self.containerView];
   }
}

- (void)setupTextView
{
   self.textView = [[UITextView alloc] init];
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
   self.textView.backgroundColor = [UIColor clearColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = NO;
   self.textView.editable = NO;

   [self.containerView.superview addSubview:self.textView];
}

- (void)setupDimLayerWithContainerView:(UIView*)containerView
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
   [self.containerView.superview bringSubviewToFront:self.containerView];
   [self.containerView.superview layoutIfNeeded];
   self.textView.layer.zPosition = 100;

   self.enlarged = !self.enlarged;

   self.dimLayer.backgroundColor = self.enlarged ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
   if (self.enlarged)
   {
      [self.containerView.superview.layer insertSublayer:self.dimLayer below:self.containerView.layer];
   }
   else
   {
      [self.dimLayer removeFromSuperlayer];
   }

   CGFloat containerViewSuperviewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewSuperviewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat scale = containerViewSuperviewWidth / CGRectGetWidth(self.containerView.frame);

   CGFloat containerViewTargetHeight = CGRectGetHeight(self.containerView.frame) * scale;
   CGFloat textViewHeight = containerViewSuperviewHeight - containerViewTargetHeight - statusBarHeight;
   CGPoint superviewCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));

   CGFloat horizontalShift = self.containerView.center.x - superviewCenter.x;
   CGFloat verticalOffset = (containerViewSuperviewHeight - containerViewTargetHeight)*.5;
   CGFloat verticalShift = self.containerView.center.y - superviewCenter.y + verticalOffset - statusBarHeight;

   CATransform3D transform = self.enlarged ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   self.textView.frame = CGRectMake(0,
                                    containerViewSuperviewHeight - textViewHeight,
                                    containerViewSuperviewWidth,
                                    textViewHeight);

   [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.containerView.layer.transform = self.enlarged ? CATransform3DScale(transform, scale, scale, 1) : CATransform3DIdentity;
      self.textView.hidden = !self.enlarged;
   } completion:nil];
}

- (void)repositionTextViewBeforeAnimationWithHeight:(CGFloat)textViewHeight
{
   CGFloat containerViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
   self.textView.frame = CGRectMake(0, containerViewHeight, containerViewWidth, textViewHeight);
}

@end
