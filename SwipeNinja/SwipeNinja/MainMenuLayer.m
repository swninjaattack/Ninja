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

-(void)loadAudio:(NSString*)music {
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_LOW];
    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    soundEngine = [SimpleAudioEngine sharedEngine];
    [soundEngine preloadBackgroundMusic:music];
    [soundEngine playBackgroundMusic:music loop:YES];
}

-(id)init{
    self = [super init];
    [self displayMenu];
    return self;
}
-(void)displayMenu {
    CCLabelTTF *titleTop = [CCLabelTTF labelWithString:@"Swipe Ninja!" fontName:@"Marker Felt" fontSize:48]; 
    CCMenuItemImage *background = [CCMenuItemImage itemFromNormalImage:@"Menu.png" selectedImage:@"menu.png" target:self selector:@selector(displaySceneSelection)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    mainMenu = [CCMenu menuWithItems:background, nil];
    titleTop.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height-titleTop.contentSize.height/2);
    //[self addChild:titleTop];
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2);
    //mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height*1/3);
    //[mainMenu alignItemsVerticallyWithPadding:40.0f];
    [self addChild:mainMenu z:2];
    if (![soundEngine isBackgroundMusicPlaying]){
        [self loadAudio:@"01 Battle Music.m4a"];
    }
}

- (void)createBackground:(CCSprite *)background {
    CCParallaxNode * parallax = [CCParallaxNode node];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    background.anchorPoint = ccp(0,0);
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    [parallax addChild:background z:-10 parallaxRatio:ccp(0.1f , 0.1f) positionOffset:ccp(0,0)];
    [self addChild:parallax z:-10];
    //[background runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.5 red:0 green:0 blue:200],[CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255], nil]]];
}
-(void)displayCredits {
    CCMenuItemImage *background = [CCMenuItemImage itemFromNormalImage:@"MenuForest.png" selectedImage:@"MenuForest.png" target:self selector:@selector(displayMenu)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    mainMenu = [CCMenu menuWithItems:background, nil];
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2);
    [self addChild:mainMenu z:2];
}

-(void)levelOneSelect{
        [self loadAudio:@"02 Boss Music.m4a"];
        [[GameManager sharedGameManager] runSceneWithID:kGameLevel1];
}

-(void)displaySceneSelection {
    CCSprite *background = [CCSprite spriteWithFile:@"MenuForest.png"];
    [self createBackground:background];
    //CCSprite *background = [CCSprite spriteWithFile:@"Menu2.png"];
    //[self createBackground:background];
    CCMenuItemImage *startNew = [CCMenuItemImage itemFromNormalImage:@"NewGame.png" selectedImage:@"NewGameSelected.png" target:self selector:@selector(levelOneSelect)];
    CCMenuItemImage *credits = [CCMenuItemImage itemFromNormalImage:@"Credits.png" selectedImage:@"CreditsSelected.png" target:self selector:@selector(displayCredits)];
    //CCMenuItemFont *levelOne = [CCMenuItemFont itemFromString:@"Level 1" target:self selector:@selector(levelOneSelect)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    mainMenu = [CCMenu menuWithItems:startNew,credits, nil];
    
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height*2/5);
    [mainMenu alignItemsHorizontallyWithPadding:40.0f];
    [self addChild:mainMenu z:2];
}

@end
