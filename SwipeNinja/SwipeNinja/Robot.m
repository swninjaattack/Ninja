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

-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody {
    if ((self = [super initWithSpriteFrameName:@"RobotSingle.png"])) {
        CGSize size = CGSizeMake(30, 30);
        self.anchorPoint = ccp(0.5, 30/self.contentSize.height);
        NSLog(@"%f, %f", self.contentSize.width, self.contentSize.height);
        [self addBoxBodyAndShapeWithLocation:location size:size space:theSpace mass:1.0 e:0.0 u:1.0 collisionType:kCollisionTypeRobot canRotate:FALSE];
        groundShapes = cpArrayNew(0);
        cpSpaceAddCollisionHandler(space, kCollisionTypeRobot, kCollisionTypeGround, begin, preSolve, NULL, separate, NULL);
        cpConstraint *constraint = cpRotaryLimitJointNew(groundBody, body, CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(0));
        cpSpaceAddConstraint(space, constraint);
        accelerationFraction = 1;
    }
    return self;
}

- (void) updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
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
        double curTime = CACurrentMediaTime();
        double timeMoving = curTime - movingStartTime;
        static double TIME_TO_MOVE = 1.0f;
        float margin = 20;
        CGPoint oldPosition = self.position;
        CGPoint newVel = body->v;
        if (groundShapes->num == 0) {
            newVel = ccp(accelerationFraction, body->v.y);
        }
        if (body->p.x < margin) {
            cpBodySetPos(body, ccp(margin, body->p.y));
        }
        
        if (body->p.x > 1600 - margin) {
            cpBodySetPos(body, ccp(1600 - margin, body->p.y));
        }
        if(timeMoving > TIME_TO_MOVE) {
            accelerationFraction *= -1;
            timeMoving = 0;
        }
        if(ABS(accelerationFraction) > 0.05) { 
            double diff = CACurrentMediaTime() - lastFlip;        
            if (diff > 0.1) {
                lastFlip = CACurrentMediaTime();
                if (oldPosition.x > self.position.x) {
                    self.flipX = YES;
                } else {
                    self.flipX = NO;
                }
            }
        }
    }
}

@end
