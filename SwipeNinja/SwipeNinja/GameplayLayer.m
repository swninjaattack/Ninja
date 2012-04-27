//
//  GameplayLayer.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 3/28/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//
#import "CPNinja.h"
#import "Robot.h"
#import "GameplayLayer.h"
#import "CPRevolvePlatform.h"
#import "CPPivotPlatform.h"
#import "CPSpringPlatform.h"
#import "CPNormalPlatform.h"
#import "GameManager.h"
#import "Constants.h"
#import "DebugNode.h"

@implementation GameplayLayer 

@synthesize foreground = _foreground;
@synthesize meta = _meta;
@synthesize tileMap = _tileMap;
@synthesize background = _background;

-(id)init {
    self = [super init];
    if (self != nil) {
        [[CCDirector sharedDirector] enableRetinaDisplay:YES];
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
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
        ninja = [[[CPNinja alloc] initWithLocation:ccp(100, 100) space:space groundBody:groundBody] autorelease];
        robot = [[[Robot alloc] initWithLocation:ccp(400,400) space:space groundBody:groundBody] autorelease];
        [self addChild:batchNode z:0];
        [batchNode addChild:ninja];
        [batchNode addChild:robot];
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

-(void)createBoxAtLocation:(CGPoint)location withWidth:(int)width {
    
    CGPoint temp = location;
    CCLOG(@"%f, %f", location.x, location.y);

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
    int span = 0;
    
    for (int height = 0; height < _tileMap.mapSize.height - 1; ++height) { 
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
                    CGPoint tempLoc = currentLoc;
                    tempLoc.x = tempLoc.x - span/2;
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
    float fixedPositionX = [CCDirector sharedDirector].winSize.width/4;
    float fixedPositionY = [CCDirector sharedDirector].winSize.height/4;
    float newX = fixedPositionX - ninja.position.x;
    float newY = fixedPositionY - ninja.position.y;

    float groundMaxX = _tileMap.mapSize.width * _tileMap.tileSize.width;
    float groundMaxY = _tileMap.mapSize.height * _tileMap.tileSize.height;
    
    newX = MIN(newX, 0);
    newY = MIN(newY, 50);
    newX = MAX(newX, -groundMaxX-fixedPositionX);
    newY = MAX(newY, -groundMaxY-fixedPositionY);
    CGPoint newPos = ccp(newX, newY);
    //CCLOG(@"%f", newY);
    [self setPosition:newPos];
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
        0,                          //set this int to draw or not
        0.0f, //4.0 makes the red boxes
        0.0f,
        0.0f,//was 1.5
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
