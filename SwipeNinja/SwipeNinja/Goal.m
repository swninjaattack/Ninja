//
//  Goal.m
//  SwipeNinja
//
//  Created by John on 4/30/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "Goal.h"

@implementation Goal

@synthesize groundShapes;

static cpBool begin(cpArbiter *arb, cpSpace *space, void *ignore) {
    CP_ARBITER_GET_SHAPES(arb, goalShape, groundShape);
    Goal *goal = (Goal *)goalShape->data;
    cpVect n = cpArbiterGetNormal(arb, 0);
    if (n.y < 0.0f) {
        cpArray *groundShapes = goal.groundShapes;
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
    CP_ARBITER_GET_SHAPES(arb, goalShape, groundShape);
    Goal *goal = (Goal *)goalShape->data;
    cpArrayDeleteObj(goal.groundShapes, groundShape);
}

-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody {
    if ((self = [super initWithSpriteFrameName:@"GoalFlag.png"])) {
        CGSize size = CGSizeMake(30, 30);
        groundShapes = cpArrayNew(0);
        self.anchorPoint = ccp(0.5, 20/self.contentSize.height);
        NSLog(@"%f, %f", self.contentSize.width, self.contentSize.height);
        [self addBoxBodyAndShapeWithLocation:location size:size space:theSpace mass:1.0 e:0.0 u:1.0 collisionType:kCollisionTypeGoal canRotate:FALSE];
        cpSpaceAddCollisionHandler(space, kCollisionTypeGoal, kCollisionTypeGround, begin, preSolve, NULL, separate, NULL);
        cpConstraint *constraint = cpRotaryLimitJointNew(groundBody, body, CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(0));
        cpSpaceAddConstraint(space, constraint);
    }
    return self;
}

@end
