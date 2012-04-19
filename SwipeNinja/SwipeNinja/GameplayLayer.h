//
//  GameplayLayer.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//
#import "chipmunk.h"
#import "cocos2d.h"
#import "drawSpace.h"
#import "cpMouse.h"

@class CPNinja;

@interface GameplayLayer : CCLayer {
    double startTime;
    cpSpace *space;
    cpBody *groundBody;
    //cpMouse *mouse;
    CPNinja *ninja;
    CCSpriteBatchNode *batchNode;
}


@end
