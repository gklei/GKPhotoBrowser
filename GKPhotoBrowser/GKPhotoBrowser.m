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
   
   [self.containerView.superview addSubview:self.textView];
}

- (void)setupDimLayerWithContainerView:(UIView*)containerView
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = containerView.superview.bounds;
   self.dimLayer.opacity = .9;
   
   [containerView.superview.layer insertSublayer:self.dimLayer below:self.containerView.layer];
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
   
   self.enlarged = !self.enlarged;
   self.dimLayer.backgroundColor = self.enlarged ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
   
   CGFloat scale = CGRectGetWidth(self.containerView.superview.frame) / CGRectGetWidth(self.containerView.frame);
   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat shiftHeight = (CGRectGetHeight(self.containerView.superview.frame) - CGRectGetHeight(self.containerView.frame)*scale) - statusBarHeight*2;
   CGFloat containerViewTargetHeight = CGRectGetHeight(self.containerView.frame) * scale;
   CGFloat textViewHeight = CGRectGetHeight(self.containerView.superview.frame) - containerViewTargetHeight - statusBarHeight;
   
   if (self.enlarged)
   {
      self.textView.frame = CGRectMake(0,
                                       CGRectGetHeight(self.containerView.superview.frame),
                                       CGRectGetWidth(self.containerView.superview.frame),
                                       textViewHeight);
   }
   
   CGAffineTransform transform = self.enlarged ? CGAffineTransformMakeTranslation(0, -shiftHeight) : CGAffineTransformIdentity;
   
   [UIView animateWithDuration:.3 animations:^{
      
      self.containerView.transform = CGAffineTransformScale(transform, scale, scale);
      
      if (self.enlarged)
      {
         self.textView.frame = CGRectMake(0,
                                          CGRectGetHeight(self.containerView.superview.frame) - textViewHeight,
                                          CGRectGetWidth(self.containerView.superview.frame),
                                          textViewHeight);
      }
      else
      {
         self.textView.frame = CGRectMake(0,
                                          CGRectGetHeight(self.containerView.superview.frame),
                                          CGRectGetWidth(self.textView.frame),
                                          CGRectGetHeight(self.textView.frame));
      }
      
      [self.containerView layoutIfNeeded];
   }];
}

@end
