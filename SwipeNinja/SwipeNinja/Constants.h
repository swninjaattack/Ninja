//
//  Constants.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/25/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

#define kVikingSpriteZValue 100
#define kVikingSpriteTagValue 0

typedef enum {
    kNoSceneUninitialized = 0,
    kMainMenuScene = 1,
    kGameLevel1 = 101
} SceneTypes;

typedef enum {
    kCollisionTypeGround = 0x1,
    kCollisionTypeNinja
} CollisionType;