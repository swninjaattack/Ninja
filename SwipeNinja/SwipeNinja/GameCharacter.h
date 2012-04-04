//
//  GameCharacter.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/26/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

#import "GameObject.h"

@interface GameCharacter : GameObject {
    int characterHealth;
    CharacterStates characterState;
}

@property (readwrite) int characterHealth;
@property (readwrite) CharacterStates characterState;

@end
