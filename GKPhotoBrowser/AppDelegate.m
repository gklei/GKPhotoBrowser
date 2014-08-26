//
//  AppDelegate.m
//  GKPhotoBrowser
//
//  Created by Klein, Greg on 8/25/14.
//  Copyright (c) 2014 HardFlip. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   MainViewController* rootViewController = [MainViewController new];
   self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
   
   self.window.rootViewController = rootViewController;
   [self.window makeKeyAndVisible];
   
   return YES;
}

@end
