//
//  GameScene.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(id)init {
    self = [super init];
    if (self != nil) {
//        BackgroundLayer *backgroundLayer = [BackgroundLayer node];
//        [self addChild:backgroundLayer z:0];
        
        GameplayLayer *gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:0];
    }
    return self;
}


@end
