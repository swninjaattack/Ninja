//
//  Constants.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/25/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

#define kNinjaSpriteZValue 100
#define kGoalSpriteZValue 50
#define kGoalSpriteTagValue 51
#define kNinjaSpriteTagValue 0

typedef enum {
    kNoSceneUninitialized = 0,
    kMainMenuScene = 1,
    kLevelCompleteScene = 50,
    kGameOverScene=51,
    kGameLevel1 = 101
} SceneTypes;

typedef enum {
    kCollisionTypeGround = 0x1,
    kCollisionTypeNinja,
    kCollisionTypeRobot,
    kCollisionTypeGoal
} CollisionType;