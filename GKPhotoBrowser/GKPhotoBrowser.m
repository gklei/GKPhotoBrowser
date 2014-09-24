//
//  GKPhotoBrowser.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "GKPhotoBrowser.h"
#import "FlatPillButton.h"
#import "UIImage+ImageEffects.h"

static NSAttributedString* _attributedLinkForImage(NSString* text, CGFloat textSize)
{
   NSURL* url = [NSURL URLWithString:@"GKPhotoBrowserImage"];
   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:textSize];
   NSDictionary* attributes = @{NSLinkAttributeName : url, NSFontAttributeName : font,
                                NSUnderlineStyleAttributeName : @1};
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

   return attributedString;
}

@interface GKPhotoBrowser () <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (weak) IBOutlet UIImageView* imageView;
@property (nonatomic) UIImage* alternateTextViewImage;

@property (nonatomic) UIView* containerView;
@property (nonatomic) UIView* topMostSuperview;
@property (nonatomic) UILabel* headerLabel;
@property (nonatomic) UITextView* textView;
@property (nonatomic) NSAttributedString* textViewAttributedText;

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
- (void)setupHeaderLabel
{
   CGFloat widthOfButtonAndPadding = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMinX(self.doneButton.frame);
   CGFloat headerWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - widthOfButtonAndPadding*2 - 8;
   CGFloat headerHeight = CGRectGetMaxY(self.doneButton.frame) - CGRectGetMinY(self.doneButton.frame);
   CGFloat headerXPosition = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetMinX(self.doneButton.frame);
   CGFloat headerYPosition = CGRectGetMinY(self.doneButton.frame);

   self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerXPosition, headerYPosition, headerWidth, headerHeight)];
   self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
   self.headerLabel.textColor = [UIColor whiteColor];
   self.headerLabel.textAlignment = NSTextAlignmentCenter;
   self.headerLabel.text = self.headerText;

   [self sizeLabel:self.headerLabel toRect:self.headerLabel.frame];
}

- (void)setupTextView
{
   self.textView = [[UITextView alloc] init];
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
   self.textView.backgroundColor = [UIColor clearColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = NO;
   self.textView.editable = NO;
   self.textView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                                        NSUnderlineColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1]};

   if (self.textViewAttributedText)
   {
      self.textView.attributedText = self.textViewAttributedText;
   }
}

- (void)setupDimLayer
{
   self.dimLayer = [CALayer layer];
   self.dimLayer.frame = [UIScreen mainScreen].bounds;
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
      [self updateImageForState:self.state];
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

- (void)setHeaderText:(NSString *)headerText
{
   if (_headerText != headerText)
   {
      _headerText = headerText;
      self.headerLabel.text = _headerText;
      [self sizeLabel:self.headerLabel toRect:self.headerLabel.frame];
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
      self.dimLayer.contents = (id)[self blurredSnapshot].CGImage;
      [self.topMostSuperview.layer addSublayer:self.dimLayer];
   }
   else
   {
      [self.dimLayer removeFromSuperlayer];
   }
}

- (void)toggleResizeWithState:(GKPhotoBrowserState)state
{
   [[UIApplication sharedApplication] setStatusBarStyle: (state != GKPhotoBrowserStateDisplay) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];

   UIView* topMostSuperview = self.topMostSuperview;
   if (self.textView.superview == nil)
   {
      [topMostSuperview addSubview:self.textView];
   }

   [topMostSuperview addSubview:self.headerLabel];
   [self updateDimLayerWithState:state];
   [self updateDoneButtonWithState:state];

   if (self.containerZoomView.superview == nil)
   {
      self.containerZoomView.frame = [self.containerView.superview convertRect:self.containerView.frame toView:topMostSuperview];
      [topMostSuperview addSubview:self.containerZoomView];
      self.containerView.hidden = YES;
   }

   CGFloat containerViewSuperviewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewSuperviewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat xScale = containerViewSuperviewWidth / CGRectGetWidth(self.containerView.frame);

   CGFloat containerViewTargetHeight;
   CGFloat yScale = xScale;
   if (self.respectsImageAspectRatio && self.imageView.image)
   {
      containerViewTargetHeight = self.imageView.image.size.height * (containerViewSuperviewWidth / self.imageView.image.size.width);
      yScale = containerViewTargetHeight / CGRectGetHeight(self.containerView.frame);
   }
   else
   {
      containerViewTargetHeight = CGRectGetHeight(self.containerView.frame) * xScale;
   }
   if (self.textView.text.length > 0)
   {
      containerViewTargetHeight = CGRectGetHeight([UIScreen mainScreen].bounds)*.55f;
      yScale = containerViewTargetHeight / CGRectGetHeight(self.containerView.frame);
   }
//   else
//   {
//      containerViewTargetHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMaxY(self.headerLabel.frame) - 20;
//   }
   CGFloat textViewHeight = containerViewSuperviewHeight - containerViewTargetHeight - statusBarHeight;

   self.textView.frame = CGRectMake(0, containerViewSuperviewHeight, containerViewSuperviewWidth, textViewHeight);
   self.textView.layer.zPosition = 100;
   self.headerLabel.layer.zPosition = 100;

   CGPoint screenCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
   CGFloat verticalOffset = (containerViewSuperviewHeight - containerViewTargetHeight)*.5;
   CGFloat verticalShift = self.containerViewCenterInSuperview.y - screenCenter.y + verticalOffset - statusBarHeight - CGRectGetHeight(self.doneButton.frame) - 15;
   CGFloat horizontalShift = self.containerViewCenterInSuperview.x - screenCenter.x;

   CATransform3D transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   void (^zoomAnimation)() = ^
   {
      self.containerZoomView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(transform, xScale, yScale, 1) : CATransform3DIdentity;
      self.textView.hidden = (state != GKPhotoBrowserStateDisplay);
      if (state == GKPhotoBrowserStateDefault)
      {
         [self.headerLabel removeFromSuperview];
      }
   };

   void (^textViewAnimation)() = ^
   {
      CGRect containerFrameInTopMostSuperview = [topMostSuperview convertRect:self.textView.superview.frame toView:topMostSuperview];
      CGFloat doneButtonVerticalPadding = CGRectGetHeight(self.doneButton.frame) + 20;
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
      if (state == GKPhotoBrowserStateDefault)
      {
         self.containerView.hidden = NO;
         [self.containerZoomView removeFromSuperview];
         [self.browserDelegate gkPhotoBrowserDidDismiss:self];
      }
   };

   if (state == GKPhotoBrowserStateDisplay)
   {
      [self.browserDelegate gkPhotoBrowserWillZoom:self];
      [UIView animateWithDuration:.25
                            delay:0
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:zoomAnimation
                       completion:zoomAnimationCompletion];
   }
   else
   {
      [self.browserDelegate gkPHotoBrowserWillDismiss:self];
      [UIView animateWithDuration:.5
                            delay:0
           usingSpringWithDamping:.75
            initialSpringVelocity:1.5
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:zoomAnimation
                       completion:zoomAnimationCompletion];
   }

   [UIView animateWithDuration:.3
                         delay:0
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:textViewAnimation
                    completion:textViewAnimationCompletion];
}

- (void)updateImageForState:(GKPhotoBrowserState)state
{
   if (state == GKPhotoBrowserStateDefault)
   {
      self.containerZoomView.layer.contents = (__bridge id)self.imageView.image.CGImage;
   }
}

- (void)setParentNavigationBarsHidden:(BOOL)hidden
{
   UIViewController* parentViewController = self.parentController.parentViewController;
   while (parentViewController != nil)
   {
      parentViewController.navigationController.navigationBarHidden = hidden;
      parentViewController = parentViewController.parentViewController;
   }
}

- (void)sizeLabel:(UILabel*)label toRect:(CGRect)labelRect
{
   // Set the frame of the label to the targeted rectangle
   label.frame = labelRect;

   // Try all font sizes from largest to smallest font size
   int fontSize = 300;
   int minFontSize = 5;

   // Fit label width wize
   CGSize constraintSize = CGSizeMake(label.frame.size.width, MAXFLOAT);

   do {
      // Set current font size
      label.font = [UIFont fontWithName:label.font.fontName size:fontSize];

      // Find label size for current font size
      CGRect textRect = [[label text] boundingRectWithSize:constraintSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:label.font}
                                                   context:nil];

      CGSize labelSize = textRect.size;

      // Done, if created label is within target size
      CGFloat labelWidth = [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}].width;
      if (labelSize.height <= CGRectGetHeight(label.frame) && labelWidth <= CGRectGetWidth(label.frame))
      {
         break;
      }

      // Decrease the font size and try again
      fontSize -= 2;

   } while (fontSize > minFontSize);
}

- (UIImage*)blurredSnapshot
{
   UIView* topMostSuperview = self.topMostSuperview;
   UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(topMostSuperview.frame),
                                                     CGRectGetHeight(topMostSuperview.frame)),
                                          NO, 1.0f);
   [topMostSuperview drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(topMostSuperview.frame), CGRectGetHeight(topMostSuperview.frame)) afterScreenUpdates:NO];
   UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();

   // Now apply the blur effect using Apple's UIImageEffect category
   UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];

   UIGraphicsEndImageContext();

   return blurredSnapshotImage;
}

#pragma mark - Public
- (void)addBrowserToContainerView:(UIView *)containerView inParentController:(UIViewController*)parentController
{
   self.parentController = parentController;
   self.containerView = containerView;
   [self.containerView addSubview:self.view];

   UIView* view = self.view;
   NSDictionary* views = NSDictionaryOfVariableBindings(view);
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
   [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];

   [self setupDoneButton];
   [self setupHeaderLabel];

   self.containerZoomView = [[UIView alloc] initWithFrame:self.containerView.frame];
}

- (void)makeCaptionSubstring:(NSString *)substring hyperlinkToDisplayImage:(UIImage *)image
{
   self.alternateTextViewImage = image;
   NSRange range = [self.textView.text rangeOfString:substring];

   if (range.length > 0)
   {
      NSString* firstSubstring = [self.textView.text substringWithRange:NSMakeRange(0, range.location)];
      NSString* secondSubstring = [self.textView.text substringFromIndex:(range.location + range.length)];

      UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
      NSDictionary* attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};

      NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:firstSubstring attributes:attributes]];
      [attributedText appendAttributedString:_attributedLinkForImage(substring, 18)];
      [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:secondSubstring attributes:attributes]];

      self.textViewAttributedText = attributedText;
      self.textView.attributedText = attributedText;
      self.textView.delegate = self;
   }
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
   self.containerZoomView.layer.contents = (__bridge id)self.alternateTextViewImage.CGImage;
   return NO;
}

@end
