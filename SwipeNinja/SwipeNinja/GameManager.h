//
//  GameManager.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameManager : NSObject {
    SceneTypes currentScene;
    
}

+(GameManager *)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;

@end
