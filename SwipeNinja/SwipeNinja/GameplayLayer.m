//
//  GameplayLayer.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//
#import "CPNinja.h"
#import "Robot.h"
#import "Goal.h"
#import "GameplayLayer.h"
#import "GameManager.h"
#import "Constants.h"
#import "DebugNode.h"

@implementation GameplayLayer 

@synthesize foreground = _foreground;
@synthesize meta = _meta;
@synthesize tileMap = _tileMap;
@synthesize background = _background;

- (void)createBackground {
    CCParallaxNode * parallax = [CCParallaxNode node];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *background;
    background = [CCSprite spriteWithFile:@"Background1.png"];
    background.anchorPoint = ccp(0,0);
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    [parallax addChild:background z:-10 parallaxRatio:ccp(0.1f , 0.1f) positionOffset:ccp(0,0)];
    [self addChild:parallax z:-10];
    //[background runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCTintTo actionWithDuration:0.5 red:0 green:0 blue:200],[CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255], nil]]];
}

-(id)init {
    self = [super init];
    if (self != nil) {
        robots = [[[NSMutableArray alloc] initWithCapacity:5] retain];
        
        for (int x=0; x<5; ++x) {
            robotStatus[x]=NO;
        }
        
        isPlayerDead = NO;
        [[CCDirector sharedDirector] enableRetinaDisplay:YES];
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"SwipeNinjaLevelOne.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        [self addChild:_tileMap z:-1];
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
        
        levelBounds.width = _tileMap.mapSize.width*_tileMap.tileSize.width;
        levelBounds.height = _tileMap.mapSize.height*_tileMap.tileSize.height;
        
        [self scheduleUpdate];        
        [self createSpace];
        
        //[self addChild:[ChipmunkDebugNode debugNodeForCPSpace:space] z:100];        
        [self createGround];
        //mouse = cpMouseNew(space);
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scene1atlas.plist"];
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scene1atlas.png"];
        ninja = [[[CPNinja alloc] initWithLocation:ccp(100,100) space:space groundBody:groundBody] autorelease];
        [[GameManager sharedGameManager] initRobotsKilled];
        [robots addObject:[[[Robot alloc] initWithLocation:ccp(170,150) space:space groundBody:groundBody] autorelease]];
        [robots addObject:[[[Robot alloc] initWithLocation:ccp(336,256) space:space groundBody:groundBody] autorelease]];
        [robots addObject:[[[Robot alloc] initWithLocation:ccp(656,336) space:space groundBody:groundBody] autorelease]];
        [robots addObject:[[[Robot alloc] initWithLocation:ccp(528,720) space:space groundBody:groundBody] autorelease]];
        [robots addObject:[[[Robot alloc] initWithLocation:ccp(768,896) space:space groundBody:groundBody] autorelease]];
        
//        [[[[robots objectAtIndex:1] alloc] initWithLocation:ccp(336,256) space:space groundBody:groundBody] autorelease];
//        [[[[robots objectAtIndex:2] alloc] initWithLocation:ccp(656,336) space:space groundBody:groundBody] autorelease];
//        [[[[robots objectAtIndex:3] alloc] initWithLocation:ccp(528,720) space:space groundBody:groundBody] autorelease];
//        [[[[robots objectAtIndex:4] alloc] initWithLocation:ccp(768,896) space:space groundBody:groundBody] autorelease];

        
        goal = [[[Goal alloc] initWithLocation:ccp(1488,1185) space:space groundBody:groundBody] autorelease];
        [self addChild:batchNode z:0];
        [batchNode addChild:goal z:kGoalSpriteZValue tag:kGoalSpriteTagValue];
        [batchNode addChild:ninja z:kNinjaSpriteZValue tag:kNinjaSpriteTagValue];
        for (int j=0; j<5; ++j) {
            [batchNode addChild:[robots objectAtIndex:j]];
        }
        [self createLevel];
        [self createBackground];
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

-(void)createBoxAtLocation:(CGPoint)location withWidth:(int)width {
    
    CGPoint temp = location;
    //CCLOG(@"%f, %f", location.x, location.y);

    temp.x = (temp.x+24.0)/2.0;
    temp.y = temp.y/2.0;
    
    cpFloat hw, hh;
    hw = 8.0f;
    hh = 2.5f;
    
    cpVect verts[] = {
        cpv(-hw * width, -hh),
        cpv(-hw * width,  hh),
        cpv( hw * width,  hh),
        cpv( hw * width, -hh)
    };
    
    cpShape *shape = cpPolyShapeNew(groundBody, 4, verts, temp);
    shape->e = 0.0;
    shape->u = 0.5;
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
//    CGSize winSize = [CCDirector sharedDirector].winSize;
//    [self createBoxAtLocation:ccp(winSize.width * 0.5, winSize.height * 0.15)];
    
    CGPoint currentLoc;
    float span = 0;
    
    for (int height = 0; height < _tileMap.mapSize.height; ++height) { 
        for (int width = 0; width < _tileMap.mapSize.width; ++width) {
            currentLoc.x = width;
            currentLoc.y = height;
            int tileGid = [_meta tileGIDAt:currentLoc];
            if (tileGid) {
                NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
                if (properties) {
                    NSString *collision = [properties valueForKey:@"Collidable"];
                    if (collision && [collision compare:@"True"] == NSOrderedSame) {
                        //[self createBoxAtLocation:[self cocosCoordForTileCoord:currentLoc]];
                        //platformLocs[width][height]=TRUE;
                        ++span;
                    } 
                }
            } else {
                if (span > 0) {
                    NSLog(@"span: %f", span);
                    NSLog(@"Location: %f, %f", currentLoc.x, currentLoc.y);
                    if (currentLoc.x == 0) {
                        currentLoc.x = 99;
                        currentLoc.y -= 1;
                    }
                    CGPoint tempLoc = currentLoc;
                    tempLoc.x = tempLoc.x - span/2.0 -1;
                    [self createBoxAtLocation:[self cocosCoordForTileCoord:tempLoc] withWidth:span];
                    span = 0;
                }
            }
        }
    }
    
    for (int i = 0; i < 100; ++i) {
        for (int j = 0; j< 100; j++) {
            
        }
    }
    
}

-(void)createGround {
    CGPoint lowerLeft = ccp(0, 10);
    CGPoint lowerRight = ccp(levelBounds.width, 10);
    
    groundBody = cpBodyNewStatic();
    
    float radius = 10.0f;
    cpShape *shape = cpSegmentShapeNew(groundBody, lowerLeft, lowerRight, radius);
    shape->e = 1.0f;
    shape->u = 1.0f;
    shape->layers ^= GRABABLE_MASK_BIT;
    shape->collision_type = kCollisionTypeGround;
    cpSpaceAddShape(space, shape);
}

- (void)followPlayer:(ccTime)dt {
    CGPoint newPos;
//    if (ninja.flipX == NO) {
//        float fixedPositionX = [CCDirector sharedDirector].winSize.width/4;
//        float fixedPositionY = [CCDirector sharedDirector].winSize.height/4;
//        float newX = fixedPositionX - ninja.position.x;
//        float newY = fixedPositionY - ninja.position.y;
//
//        float groundMaxX = _tileMap.mapSize.width * _tileMap.tileSize.width;
//        float groundMaxY = _tileMap.mapSize.height * _tileMap.tileSize.height;
//        
//        newX = MIN(newX, 0);
//        newY = MIN(newY, 50);
//        newX = MAX(newX, -groundMaxX-fixedPositionX);
//        newY = MAX(newY, -groundMaxY-fixedPositionY);
//        newPos = ccp(newX, newY);
//    } else if (ninja.flipX == YES) {
//        float fixedPositionX = [CCDirector sharedDirector].winSize.width/1.5;
//        float fixedPositionY = [CCDirector sharedDirector].winSize.height/4;
//        float newX = fixedPositionX - ninja.position.x;
//        float newY = fixedPositionY - ninja.position.y;
//        
//        float groundMaxX = _tileMap.mapSize.width * _tileMap.tileSize.width;
//        float groundMaxY = _tileMap.mapSize.height * _tileMap.tileSize.height;
//        
//        newX = MIN(newX, 0);
//        newY = MIN(newY, 50);
//        newX = MAX(newX, -groundMaxX-fixedPositionX);
//        newY = MAX(newY, -groundMaxY-fixedPositionY);
//        newPos = ccp(newX, newY);
//    }
   // [self setPosition:newPos];
    
    [self runAction:[CCFollow actionWithTarget:ninja worldBoundary:CGRectMake(0,0,3200,3200)]];
}

- (void)update:(ccTime)dt {
    
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;    
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }    
    
    
    for (int i=0; i<5; ++i) {
        if (robotStatus[i] != YES) {
            if ([[robots objectAtIndex:i] characterState] == kStateDead) {
                [[robots objectAtIndex:i] removeBody];
                [batchNode removeChild:[robots objectAtIndex:i] cleanup:YES];
                robotStatus[i] = YES;
            }
        }
    }

    
    if (isPlayerDead != YES) {
        if ([ninja characterState] == kStateDead) {
            [batchNode removeChild:ninja cleanup:YES];
            [[GameManager sharedGameManager] runSceneWithID:kGameOverScene];
            isPlayerDead = YES;
        }
        if ([ninja characterState] == kLevelCompleted) {
            for (int i=0; i<5; ++i) {
                if (robotStatus[i] == YES) {
                    [[GameManager sharedGameManager] addRobotKilled];
                }
            }
            [[GameManager sharedGameManager] runSceneWithID:kLevelCompleteScene];
        }
    }
    
    while (timeAccumulator >= UPDATE_INTERVAL) {        
        timeAccumulator -= UPDATE_INTERVAL;        
        cpSpaceStep(space, UPDATE_INTERVAL);
    }
    
    CCArray *listOfGameObjects = [batchNode children];
    
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
    }
    [self followPlayer:dt];

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
        0,      //set this int to draw boxes or not
        0.0f,   //was 4.0 makes the red boxes
        0.0f,
        0.0f,   //was 1.5
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

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

- (CGPoint)cocosCoordForTileCoord:(CGPoint)position {
    int x = position.x * _tileMap.tileSize.width;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (_tileMap.tileSize.height * position.y);
    return ccp(x, y);
}

- (void)dealloc {
    self.meta = nil;
    self.foreground = nil;
    self.tileMap = nil;
    self.background = nil;
    [super dealloc];
}
@end
