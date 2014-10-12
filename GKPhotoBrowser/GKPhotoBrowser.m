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

static void _sizeLabelToRect(UILabel* label, CGRect labelRect)
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

static UIImage* _blurredSnapshotOfView(UIView* view)
{
   UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)), NO, 1.0f);
   [view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)) afterScreenUpdates:NO];
   UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
   UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
   UIGraphicsEndImageContext();

   return blurredSnapshotImage;
}

@interface GKPhotoBrowser () <UIGestureRecognizerDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (weak) IBOutlet UIImageView* imageView;
@property (nonatomic) UIImage* alternateTextViewImage;

@property (nonatomic) UIView* containerView;
@property (nonatomic) UIView* topMostSuperview;
@property (nonatomic) UILabel* headerLabel;
@property (nonatomic) UITextView* textView;
@property (nonatomic) NSAttributedString* textViewAttributedText;

@property (nonatomic) UIView* containerZoomView;
@property (nonatomic) UIScrollView* scrollZoomView;
@property (nonatomic) UIScrollView* interactableScrollView;
@property (nonatomic) UIImageView* scrollImageView;
@property (nonatomic) UIViewController* parentController;

@property (nonatomic) CALayer* topDimLayer;
@property (nonatomic) CALayer* dimLayer;
@property (nonatomic) CALayer* scrollDimLayer;
@property (nonatomic) FlatPillButton* doneButton;
@property (nonatomic, readonly) CGPoint containerViewCenterInSuperview;

@property (nonatomic) CGPoint initialScrollZoomViewOffset;
@property (nonatomic) CGPoint initialInteractableScrollViewOffset;
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
      self.maximumTargetHeightScreenPercentage = .55f;
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

   self.imageView.contentMode = UIViewContentModeScaleAspectFill;
   self.imageView.layer.masksToBounds = YES;
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

   self.topDimLayer = [CALayer layer];
   self.topDimLayer.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetMaxY(self.doneButton.frame) + 15);
   self.topDimLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:.25].CGColor;

   _sizeLabelToRect(self.headerLabel, self.headerLabel.frame);
}

- (void)setupTextView
{
   self.textView = [[UITextView alloc] init];
   [self.textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
   self.textView.backgroundColor = [UIColor clearColor];
   self.textView.textColor = [UIColor whiteColor];
   self.textView.showsVerticalScrollIndicator = YES;
   self.textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
   self.textView.editable = NO;
   self.textView.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                                        NSUnderlineColorAttributeName : [UIColor colorWithRed:0 green:1 blue:1 alpha:1]};
   self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 10, 0);

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

   UIFont* font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
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
      _sizeLabelToRect(self.headerLabel, self.headerLabel.frame);
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
   [self.textView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
      self.dimLayer.contents = (id)_blurredSnapshotOfView(self.topMostSuperview).CGImage;
      [self.topMostSuperview.layer addSublayer:self.dimLayer];
      [self.topMostSuperview.layer addSublayer:self.topDimLayer];
   }
   else
   {
      [self.dimLayer removeFromSuperlayer];
   }
}

- (void)toggleResizeWithState:(GKPhotoBrowserState)state
{
   UIStatusBarStyle statusBarStyle = (state != GKPhotoBrowserStateDisplay) ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
   [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle];

   UIView* topMostSuperview = self.topMostSuperview;
   if (self.textView.superview == nil)
   {
      [topMostSuperview addSubview:self.textView];
   }

   [topMostSuperview addSubview:self.headerLabel];
   [self updateDimLayerWithState:state];
   [self updateDoneButtonWithState:state];

   CGFloat containerViewSuperviewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
   CGFloat containerViewSuperviewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

   CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
   CGFloat xScale = containerViewSuperviewWidth / CGRectGetWidth(self.containerView.frame);

   CGFloat containerViewTargetHeight;
   CGFloat yScale = xScale;

   containerViewTargetHeight = self.imageView.image.size.height * (containerViewSuperviewWidth / self.imageView.image.size.width);
   yScale = containerViewTargetHeight / CGRectGetHeight(self.containerView.frame);

   if (self.state == GKPhotoBrowserStateDisplay)
   {
      self.scrollZoomView.frame = [self.containerView.superview convertRect:self.containerView.frame toView:topMostSuperview];

      CGFloat imageViewTargetHeight = self.imageView.image.size.height * (CGRectGetWidth(self.containerView.frame) / self.imageView.image.size.width);
      CGFloat imageViewTargetWidth = self.imageView.image.size.width * (CGRectGetHeight(self.containerView.frame) / self.imageView.image.size.height);

      CGRect imageViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), imageViewTargetHeight);
      if (imageViewTargetWidth > CGRectGetWidth(self.containerView.frame))
      {
         imageViewFrame = CGRectMake(0, 0, imageViewTargetWidth, CGRectGetHeight(self.containerView.frame));
      }

      [self.scrollImageView removeFromSuperview];
      self.scrollImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
      self.scrollImageView.image = self.imageView.image;

      CGFloat initialXOffset = (CGRectGetWidth(imageViewFrame) - CGRectGetWidth(self.containerView.frame))*.5;
      CGFloat initialYOffset = (CGRectGetHeight(imageViewFrame) - CGRectGetHeight(self.containerView.frame))*.5;
      [self.scrollZoomView addSubview:self.scrollImageView];

      self.initialScrollZoomViewOffset = CGPointMake(initialXOffset, initialYOffset);
      self.scrollZoomView.contentOffset = self.initialScrollZoomViewOffset;
      self.scrollZoomView.backgroundColor = [UIColor colorWithRed:.25 green:.1 blue:.2 alpha:.5];

      [topMostSuperview addSubview:self.scrollZoomView];
      self.containerView.hidden = YES;

      CGFloat maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds)*self.maximumTargetHeightScreenPercentage;
      containerViewTargetHeight = MIN(containerViewTargetHeight, maxHeight);
      yScale = containerViewTargetHeight / CGRectGetHeight(self.containerView.frame);
   }

   CGFloat textViewHeight = containerViewSuperviewHeight - containerViewTargetHeight - statusBarHeight - 5;

   self.textView.frame = CGRectMake(0, containerViewSuperviewHeight, containerViewSuperviewWidth, textViewHeight);
   self.textView.layer.zPosition = 100;
   self.headerLabel.layer.zPosition = 100;

   CGPoint screenCenter = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
   CGFloat verticalOffset = (containerViewSuperviewHeight - containerViewTargetHeight)*.5;
   CGFloat verticalShift = self.containerViewCenterInSuperview.y - screenCenter.y + verticalOffset - statusBarHeight - CGRectGetHeight(self.doneButton.frame) - 20;
   CGFloat horizontalShift = self.containerViewCenterInSuperview.x - screenCenter.x;

   CATransform3D transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DMakeTranslation(-horizontalShift, -verticalShift, 0) : CATransform3DIdentity;

   void (^zoomAnimation)() = ^
   {
      if (self.scrollZoomView.superview != nil)
      {
         if (self.state == GKPhotoBrowserStateDefault)
         {
            [self.scrollDimLayer removeFromSuperlayer];
            self.scrollDimLayer = nil;
            self.scrollZoomView.contentOffset = self.initialScrollZoomViewOffset;
         }
         self.scrollZoomView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(transform, xScale, yScale, 1) : CATransform3DIdentity;

         CGFloat imageViewXScale = 1/xScale;
         imageViewXScale *= containerViewSuperviewWidth / CGRectGetWidth(self.scrollImageView.frame);

         CGFloat imageViewYScale = 1/yScale;
         imageViewYScale *= containerViewSuperviewWidth / CGRectGetWidth(self.scrollImageView.frame);

         self.scrollImageView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(self.scrollImageView.layer.transform, imageViewXScale, imageViewYScale, 1) : CATransform3DIdentity;
      }
      else
      {
         self.containerZoomView.layer.transform = (state == GKPhotoBrowserStateDisplay) ? CATransform3DScale(transform, xScale, yScale, 1) : CATransform3DIdentity;
      }

      self.textView.hidden = (state != GKPhotoBrowserStateDisplay);
      if (state == GKPhotoBrowserStateDefault)
      {
         self.scrollZoomView.layer.masksToBounds = YES;
         self.scrollZoomView.hidden = NO;
         self.interactableScrollView.contentOffset = self.initialInteractableScrollViewOffset;
         [self.interactableScrollView removeFromSuperview];
         self.interactableScrollView = nil;
         [self.headerLabel removeFromSuperview];
         [self.topDimLayer removeFromSuperlayer];
      }
   };

   void (^textViewAnimation)() = ^
   {
      CGRect containerFrameInTopMostSuperview = [topMostSuperview convertRect:self.textView.superview.frame toView:topMostSuperview];
      CGFloat doneButtonVerticalPadding = CGRectGetHeight(self.doneButton.frame) + 20;
      self.textView.frame = CGRectMake(0,
                                       containerViewSuperviewHeight - textViewHeight - CGRectGetMinY(containerFrameInTopMostSuperview) + doneButtonVerticalPadding,
                                       containerViewSuperviewWidth,
                                       textViewHeight - doneButtonVerticalPadding);
   };

   void (^textViewAnimationCompletion)(BOOL finished) = ^(BOOL finished)
   {
      if (state == GKPhotoBrowserStateDisplay)
      {
         self.scrollZoomView.layer.masksToBounds = NO;
         self.interactableScrollView = [[UIScrollView alloc] initWithFrame:self.scrollZoomView.frame];
         self.interactableScrollView.delegate = self;
         self.interactableScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
         self.interactableScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:.25];

         CGFloat imageViewTargetHeight = self.imageView.image.size.height * (CGRectGetWidth(self.interactableScrollView.frame) / self.imageView.image.size.width);
         CGFloat imageViewTargetWidth = self.imageView.image.size.width * (CGRectGetHeight(self.interactableScrollView.frame) / self.imageView.image.size.height);

         CGRect imageViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.interactableScrollView.frame), imageViewTargetHeight);
         if (imageViewTargetWidth > CGRectGetWidth(self.interactableScrollView.frame))
         {
            imageViewFrame = CGRectMake(0, 0, imageViewTargetWidth, CGRectGetHeight(self.interactableScrollView.frame));
         }
         UIImageView* newImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
         newImageView.image = self.scrollImageView.image;
         [self.interactableScrollView addSubview:newImageView];
         self.interactableScrollView.contentSize = newImageView.frame.size;

         CGFloat initialXOffset = (CGRectGetWidth(imageViewFrame) - CGRectGetWidth(self.interactableScrollView.frame))*.5;
         CGFloat initialYOffset = (CGRectGetHeight(imageViewFrame) - CGRectGetHeight(self.interactableScrollView.frame))*.5;

         self.initialInteractableScrollViewOffset = CGPointMake(initialXOffset, initialYOffset);
         self.interactableScrollView.contentOffset = self.initialInteractableScrollViewOffset;

         if (CGRectGetHeight(imageViewFrame) > containerViewSuperviewHeight * self.maximumTargetHeightScreenPercentage)
         {
            [topMostSuperview addSubview:self.interactableScrollView];
            self.scrollZoomView.hidden = YES;
         }

         self.scrollDimLayer = [CALayer layer];
         self.scrollDimLayer.frame = self.interactableScrollView.bounds;
         self.scrollDimLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:.75].CGColor;

         CATextLayer* scrollLabel = [CATextLayer layer];
         scrollLabel.alignmentMode = kCAAlignmentCenter;
         scrollLabel.string = @"Scroll to view entire image";

         NSString* fontName = @"HelveticaNeue-CondensedBold";
         scrollLabel.font = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
         scrollLabel.fontSize = 18;
         scrollLabel.foregroundColor = [UIColor whiteColor].CGColor;
         scrollLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollDimLayer.frame), 40);
         scrollLabel.string = @"Scroll to view entire image";

         scrollLabel.contentsScale = [UIScreen mainScreen].scale;

         scrollLabel.position = CGPointMake(CGRectGetMidX(self.scrollDimLayer.bounds), CGRectGetMidY(self.scrollDimLayer.bounds));
         [self.scrollDimLayer addSublayer:scrollLabel];
         [self.interactableScrollView.layer addSublayer:self.scrollDimLayer];

         [self.browserDelegate gkPhotoBrowserDidZoom:self];
      }
   };

   void (^zoomAnimationCompletion)(BOOL) = ^(BOOL finished)
   {
      if (state == GKPhotoBrowserStateDefault)
      {
         self.containerView.hidden = NO;
         [self.scrollZoomView removeFromSuperview];
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
   self.scrollZoomView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
   self.scrollZoomView.layer.cornerRadius = 4.f;
//   self.scrollZoomView.layer.masksToBounds = YES;
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

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   if (self.scrollDimLayer)
   {
      [self.scrollDimLayer removeFromSuperlayer];
      self.scrollDimLayer = nil;
   }
}

@end
