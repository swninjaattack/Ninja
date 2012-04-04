//
//  GameplayLayer.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "GameplayLayer.h"

@implementation GameplayLayer 

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = YES;
        ninjaSprite = [CCSprite spriteWithFile:@"Ninja.png"];
        [ninjaSprite setPosition:CGPointMake(screenSize.width/2, 40)];
        [self addChild:ninjaSprite];
    }
    return self;
}

@end
