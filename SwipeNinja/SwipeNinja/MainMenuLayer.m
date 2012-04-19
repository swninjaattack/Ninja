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
-(void)displaySceneSelection;
@end

@implementation MainMenuLayer

-(id)init{
    self = [super init];
    CCLabelTTF *titleTop = [CCLabelTTF labelWithString:@"Main Menu" fontName:@"Marker Felt" fontSize:48];
    CCMenuItemFont *startNew = [CCMenuItemFont itemFromString:@"New Game" target:self selector:@selector(displayMenu)];
    CCMenu *menu = [CCMenu menuWithItems:startNew, nil];
    titleTop.position = ccp(160,160);
    [self addChild:titleTop];
    
    menu.position = ccp(160,220);
    [menu alignItemsVerticallyWithPadding:40.0f];
    [self addChild:menu z:2];
    return self;
}
-(void)displayMenu {
    [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
}

-(void)displaySceneSelection {
    
}

@end
