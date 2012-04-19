//
//  MainMenuLayer.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/29/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "MainMenuLayer.h"

@interface MainMenuLayer()
-(void)displayMenu;
-(void)levelOneSelect;
-(void)displaySceneSelection;
@end

@implementation MainMenuLayer

-(id)init{
    self = [super init];
    [self displayMenu];
    return self;
}
-(void)displayMenu {
    CCLabelTTF *titleTop = [CCLabelTTF labelWithString:@"Swipe Ninja!" fontName:@"Marker Felt" fontSize:48];
    CCMenuItemFont *startNew = [CCMenuItemFont itemFromString:@"New Game?" target:self selector:@selector(displaySceneSelection)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    mainMenu = [CCMenu menuWithItems:startNew, nil];
    titleTop.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height-titleTop.contentSize.height/2);
    [self addChild:titleTop];
    
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height*1/3);
    [mainMenu alignItemsVerticallyWithPadding:40.0f];
    [self addChild:mainMenu z:2];
}


-(void)levelOneSelect{
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
}

-(void)displaySceneSelection {
    CCMenuItemFont *levelOne = [CCMenuItemFont itemFromString:@"Level 1" target:self selector:@selector(levelOneSelect)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    mainMenu = [CCMenu menuWithItems:levelOne, nil];
    
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/3,[CCDirector sharedDirector].winSize.height*4/6);
    [mainMenu alignItemsVerticallyWithPadding:20.0f];
    [self addChild:mainMenu z:2];
}

@end
