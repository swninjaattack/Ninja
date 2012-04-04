//
//  MainMenuScene.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "MainMenuScene.h"

@implementation MainMenuScene
-(id)init {
    self = [super init];
    if (self != nil) {
        mainMenuLayer = [MainMenuLayer node];
        [self addChild:mainMenuLayer];
    }
    return self;
}

@end
