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
    CGSize levelBounds;
    CCSpriteBatchNode *batchNode;
    BOOL platformLocs[100][100];
    
    CCTMXLayer *_meta;
    CCTMXLayer *_foreground;
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    
}

@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;

@end
