//
//  Robot.m
//  SwipeNinja
//
//  Created by John on 4/26/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "Robot.h"

@implementation Robot

@synthesize groundShapes;
@synthesize walkingAnim;

static cpBool begin(cpArbiter *arb, cpSpace *space, void *ignore) {
    CP_ARBITER_GET_SHAPES(arb, robotShape, groundShape);
    Robot *robot = (Robot *)robotShape->data;
    cpVect n = cpArbiterGetNormal(arb, 0);
    if (n.y < 0.0f) {
        cpArray *groundShapes = robot.groundShapes;
        cpArrayPush(groundShapes, groundShape);
    }
    return cpTrue;
}

static cpBool preSolve(cpArbiter *arb, cpSpace *space, void *ignore) {
    if(cpvdot(cpArbiterGetNormal(arb, 0), ccp(0, -1)) < 0) {
        return cpFalse;
    }
    return cpTrue;
}

static void separate(cpArbiter *arb, cpSpace *space, void *ignore) {
    CP_ARBITER_GET_SHAPES(arb, robotShape, groundShape);
    Robot *robot = (Robot *)robotShape->data;
    cpArrayDeleteObj(robot.groundShapes, groundShape);
}


- (void)initAnimations
{
    NSMutableArray *walkFrames = [[[NSMutableArray alloc] initWithCapacity:4] retain];
    for (int i=1; i<=4; ++i) {
        [walkFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Robot%d.png", i]]];
    }
    self.walkingAnim = [CCAnimation animationWithFrames:walkFrames delay:0.25f];
                               //CURRENT VERSION
//    walkingAnim = [[self loadPlistForAnimationWithName:@"walkingAnim" andClassName:NSStringFromClass([self class])] retain];
//    [[CCAnimationCache sharedAnimationCache] addAnimation:walkingAnim name:@"walkingAnim"];

    //OLD STUFF
//    walkingAnimation = [CCAnimation animation];
//    [walkingAnimation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Robot2.png"]];
//    [walkingAnimation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Robot3.png"]];
//    [walkingAnimation addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Robot4.png"]];
//    
    //    [self setWalkingAnim:
    //     [self loadPlistForAnimationWithName:@"walkingAnim" 
    //      andClassName:NSStringFromClass([self class])]];
}


-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody {
    if ((self = [super initWithSpriteFrameName:@"Robot1.png"])) {
        CGSize size = CGSizeMake(30, 30);
        characterHealth = 100.0f;
        self.anchorPoint = ccp(0.5, 20/self.contentSize.height);
        NSLog(@"%f, %f", self.contentSize.width, self.contentSize.height);
        [self addBoxBodyAndShapeWithLocation:location size:size space:theSpace mass:1.0 e:0.0 u:1.0 collisionType:kCollisionTypeRobot canRotate:FALSE];
        groundShapes = cpArrayNew(0);
        cpSpaceAddCollisionHandler(space, kCollisionTypeRobot, kCollisionTypeGround, begin, preSolve, NULL, separate, NULL);
        cpConstraint *constraint = cpRotaryLimitJointNew(groundBody, body, CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(0));
        cpSpaceAddConstraint(space, constraint);
        accelerationFraction = 1;
        [self initAnimations];
    }
    return self;
}

- (void) changeState:(CharacterStates)newState {
    if (characterState == newState ) {
        return;
    }
    [self stopAllActions];
    id action = nil;
    [self setCharacterState:newState];
    switch(newState){
            case kStateWalking:
            //[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Robot1.png"]];
            movingStartTime = CACurrentMediaTime();
            //CURRENT VERSION
            action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkingAnim restoreOriginalFrame:NO]];
            break;
            case kStateTakingDamage:
                characterHealth -= 50.0f;
                if (characterHealth <=0.0f){
                    [self changeState:kStateDead];
                }
                else {
                    action = [CCBlink actionWithDuration:1.0 blinks:3.0];
                }
            break;
            case kStateRotating:
            {
                CCFlipX *flip = [CCFlipX actionWithFlipX:!self.flipX];
                action = [CCSequence actions:flip, nil];
                [self changeState:kStateWalking];
                break;
            }
            case kStateDead:
            CCLOG(@"Changing state to dead");
            default:
            break;
    }
    if (action!=nil) {
        [self runAction:action];
    }
}

- (void) removeBody {
    cpSpaceRemoveBody(space, body);
    cpSpaceRemoveShape(space, shape);
}

- (void) updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
    [super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
    if (characterState == kStateDead)
        return;
    ninja = (CPSprite *) [[self parent] getChildByTag:kNinjaSpriteTagValue];
    CGRect ninjaBoundingBox = [ninja adjustedBoundingBox];
    CharacterStates ninjaState = [ninja characterState];
    if ((ninjaState == kStateAttacking) && (CGRectIntersectsRect([self adjustedBoundingBox], ninjaBoundingBox))){
        if(characterState != kStateTakingDamage) {
            [self changeState:kStateTakingDamage];
            return;
        }
    }
    if((characterState == kStateTakingDamage) && ([self numberOfRunningActions] > 0 )) {
        return;
    }
    
    if ((characterState == kStateTakingDamage) && ([self numberOfRunningActions] == 0))
    {
        [self changeState:kStateRotating];
    }
    if (characterState != kStateWalking && [self numberOfRunningActions] == 0) {
        [self changeState:kStateWalking];
    }
    if (characterState == kStateWalking) { 
        //OLD STUFF
//        id robotAnimationAction =
//        [CCAnimate actionWithDuration:0.5f
//                            animation:walkingAnimation
//                 restoreOriginalFrame:NO];                       
//        id repeatRobotAnimation =
//        [CCRepeatForever actionWithAction:robotAnimationAction];  
//        [self runAction:repeatRobotAnimation];
        
        double curTime = CACurrentMediaTime();
        double timeMoving = curTime - movingStartTime;
        static double TIME_TO_MOVE = 1.5f;
        float margin = 20;
        CGPoint newVel = body->v;
        if (body->p.x < margin) {
            cpBodySetPos(body, ccp(margin, body->p.y));
        }
        
        if (body->p.x > 1600 - margin) {
            cpBodySetPos(body, ccp(1600 - margin, body->p.y));
        }
        if(timeMoving > TIME_TO_MOVE) {
            accelerationFraction *= -1;
            movingStartTime = CACurrentMediaTime();
            [self changeState:kStateRotating];
        }
        if (groundShapes->num > 0) {
                float maxSpeed = 40.0f;
                newVel = ccp(-maxSpeed*accelerationFraction, 0);
                cpBodyActivate(body);
        } else {
            shape->surface_v = cpvzero;
        }
        cpBodySetVel(body, newVel);
    }
}

@end
