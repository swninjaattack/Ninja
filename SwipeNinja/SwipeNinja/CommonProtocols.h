//
//  CommonProtocols.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/25/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

typedef enum {
    kStateIdle,
    kStateWalking,
    kStateJumping,
    kStateTakingDamage,
    kStateDead
} CharacterStates;

typedef enum {
    kObjectTypeNone,
    kEnemyTypeThug,
    kNinjaType
} GameObjectType;

@protocol GameplayLayerDelegate
            
- (void)createObjectOfType:(GameObjectType)objectType 
                withHealth:(int)initialHealth 
                atLocation:(CGPoint)spawnLocation
                withZValue:(int)zValue;
@end