//
//  GameManager.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "GameManager.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "GameOver.h"
#import "LevelCompleted.h"
#import "GameScene.h"
#import "chipmunk.h"


@implementation GameManager
static GameManager* _sharedGameManager = nil;

+(GameManager *)sharedGameManager {
    @synchronized([GameManager class]) {
        if(!_sharedGameManager)
            [[self alloc] init];
        return _sharedGameManager;
    }
}

+(id)alloc {
    @synchronized ([GameManager class]) {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allowcate a second instance of the Game Manager");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
}


-(id)init {
    self = [super init];
    if (self != nil) {
        currentScene = kNoSceneUninitialized;
        numOfRobotsKilled=0;
        cpInitChipmunk();
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene:
            sceneToRun = [MainMenuScene node];
            break;
        case kGameLevel1:
            sceneToRun = [GameScene node];
            break;
        case kLevelCompleteScene:
            sceneToRun = [LevelCompleted node];
            break;
        case kGameOverScene:
            sceneToRun = [GameOver node];
            break;
        default:
            CCLOG(@"Unknown Scene");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        currentScene = oldScene;
        return;
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil)
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    else 
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
}

-(void)addRobotKilled {
    ++numOfRobotsKilled;
}

-(int)robotsKilled {
    return numOfRobotsKilled;
}

@end