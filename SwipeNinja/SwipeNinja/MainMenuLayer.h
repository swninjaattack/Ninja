//
//  MainMenuLayer.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "GameManager.h"
#import "SimpleAudioEngine.h"

@interface MainMenuLayer : CCLayer {
    CCMenu *mainMenu;
    SimpleAudioEngine *soundEngine;
    bool newGame;
}
@end
