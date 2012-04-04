//
//  AppDelegate.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright University of Miami 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
