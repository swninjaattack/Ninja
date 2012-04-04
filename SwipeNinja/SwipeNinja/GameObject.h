//
//  GameObject.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/25/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "CCSprite.h"
#import "CommonProtocols.h"

@interface GameObject : CCSprite {
    BOOL isActive;
    BOOL reactsToScreenBoundaries;
    CGSize screenSize;
    GameObjectType gameObjectType;
}

@property (readwrite) BOOL isActive;
@property (readwrite) BOOL reactsToScreenBoundaries;
@property (readwrite) CGSize screenSize;
@property (readwrite) GameObjectType gameObjectType;

- (void)changeState:(CharacterStates)newState;
- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects;
- (CGRect)adjustedBoundingBox;
- (CCAnimation *)loadPlistForAnimationWithName:(NSString *)animationName andClassName:(NSString *)className;

@end
