//
//  GameplayLayer.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//
#import "CPNinja.h"
#import "GameplayLayer.h"
#import "CPRevolvePlatform.h"
#import "CPPivotPlatform.h"
#import "CPSpringPlatform.h"
#import "CPNormalPlatform.h"
#import "GameManager.h"
#import "Constants.h"

@implementation GameplayLayer 

-(id)init {
    self = [super init];
    if (self != nil) {
        [self scheduleUpdate];
        [self createSpace];
        [self createGround];
        //mouse = cpMouseNew(space);
        self.isTouchEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scene1atlas.plist"];
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1atlas.png"];
        ninja = [[[CPNinja alloc] initWithLocation:ccp(100, 100) space:space groundBody:groundBody] autorelease];
        [self addChild:batchNode z:0];
        [batchNode addChild:ninja];
        [self createLevel];
        
        //ninjaSprite = [CCSprite spriteWithFile:@"Ninja.png"];
        //[ninjaSprite setPosition:CGPointMake(screenSize.width/2, 40)];
        //[self addChild:ninjaSprite];
    }
    
    return self;
}

-(void)createSpace {
    space = cpSpaceNew();
    
    space->gravity = ccp(0, -750);
    
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
}

-(void)createBoxAtLocation:(CGPoint)location {
    
    cpFloat hw, hh;
    hw = 50.0/2.0f;
    hh = 5.0/2.0f;
    
    cpVect verts[] = {
        cpv(-hw, -hh),
        cpv(-hw,  hh),
        cpv( hw,  hh),
        cpv( hw, -hh)
    };
    
    cpShape *shape = cpPolyShapeNew(groundBody, 4, verts, location);
    shape->e = 1.0;
    shape->u = 1.0;
    shape->collision_type = kCollisionTypeGround;
    cpSpaceAddShape(space, shape);

//    float boxSize = 60.0;
//    float mass = 1.0;
//    cpBody *body = cpBodyNew(mass, cpMomentForBox(mass, boxSize, boxSize));
//    body->p = location;
//    
//    cpSpaceAddBody(space, body);
//    
//    cpShape *shape = cpBoxShapeNew(body, boxSize, boxSize);
//    shape->e = 0.0;
//    shape->u = 0.5;
}

-(void)createLevel {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self createBoxAtLocation:ccp(winSize.width * 0.5, winSize.height * 0.15)];
}

-(void)createGround {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint lowerLeft = ccp(0, 0);
    CGPoint lowerRight = ccp(winSize.width, 0);
    
    groundBody = cpBodyNewStatic();
    
    float radius = 10.0f;
    cpShape *shape = cpSegmentShapeNew(groundBody, lowerLeft, lowerRight, radius);
    shape->e = 1.0f;
    shape->u = 1.0f;
    shape->layers ^= GRABABLE_MASK_BIT;
    shape->collision_type = kCollisionTypeGround;
    cpSpaceAddShape(space, shape);
}

- (void)update:(ccTime)dt {
    
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }    
    
    while (timeAccumulator >= UPDATE_INTERVAL) {        
        timeAccumulator -= UPDATE_INTERVAL;        
        cpSpaceStep(space, UPDATE_INTERVAL);
    }
    
    CCArray *listOfGameObjects = [batchNode children];
    
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
    }

//    CCArray *listOfGameObjects = [sceneSpriteBatchNode children]; 
//    for (GameCharacter *tempChar in listOfGameObjects) { 
//        [tempChar updateStateWithDeltaTime:dt 
//                      andListOfGameObjects:listOfGameObjects]; 
//    }    
//    
//    [self followPlayer:dt];
    
//    if (remainingTime <= 0) {
//        [[GameManager sharedGameManager] setHasPlayerDied:YES];
//        [[GameManager sharedGameManager] 
//         runSceneWithID:kLevelCompleteScene];   
//    } else if (viking.position.y > 2900) {
//        [[GameManager sharedGameManager] setHasPlayerDied:NO];
//        [[GameManager sharedGameManager] 
//         runSceneWithID:kLevelCompleteScene];   
//    }
    
}

- (void)draw {
    drawSpaceOptions options = {
        0,
        0,
        1,
        4.0f,
        0.0f,
        1.5f,
    };
    drawSpace(space, &options);
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//    cpMouseGrab(mouse, touchLocation, false);
    
    [ninja ccTouchBegan:touch withEvent:event];
    return YES;
}


//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
////    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
////    cpMouseMove(mouse, touchLocation);
//    
//}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
//    cpMouseRelease(mouse);
    
    [ninja ccTouchEnded:touch withEvent:event];    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [ninja accelerometer:accelerometer didAccelerate:acceleration];
}
@end
