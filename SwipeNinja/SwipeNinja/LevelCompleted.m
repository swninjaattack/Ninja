//
//  LevelCompleted.m
//  SwipeNinja
//
//  Created by John on 4/30/12.
//  Copyright 2012 University of Miami. All rights reserved.
//

#import "LevelCompleted.h"


@implementation LevelCompleted


-(id)init {
    self = [super init];
    [self createBackground];
    CCMenuItemImage *background = [CCMenuItemImage itemFromNormalImage:@"Invisible.png" selectedImage:@"Invisible.png" target:self selector:@selector(displayMenu)];
    if (mainMenu != nil) {
        [mainMenu removeFromParentAndCleanup:YES];
    }
    CCLabelTTF *robotCountLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Robots Killed: %d", [[GameManager sharedGameManager] robotsKilled]] fontName:@"Marker Felt" fontSize:32];
    robotCountLabel.position = ccp([CCDirector sharedDirector].winSize.width/2, [CCDirector sharedDirector].winSize.height/2);
    [self addChild:robotCountLabel];
    
    mainMenu = [CCMenu menuWithItems:background, nil];
    mainMenu.position = ccp([CCDirector sharedDirector].winSize.width/2,[CCDirector sharedDirector].winSize.height/2);
    [self addChild:mainMenu z:2];
    return self;
}

-(void)displayMenu {
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

- (void)createBackground {
    CCParallaxNode * parallax = [CCParallaxNode node];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *background;
    background = [CCSprite spriteWithFile:@"WinScreen.png"];
    background.anchorPoint = ccp(0,0);
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    [parallax addChild:background z:-10 parallaxRatio:ccp(0.1f , 0.1f) positionOffset:ccp(0,0)];
    [self addChild:parallax z:-10];
    //[background runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.5 red:0 green:0 blue:200],[CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255], nil]]];
}

@end
