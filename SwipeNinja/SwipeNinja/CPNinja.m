//
//  CPNinja.m
//  SwipeNinja
//
//  Created by Ryan Lesko on 4/15/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "CPNinja.h"

@implementation CPNinja

@synthesize groundShapes;
@synthesize attackAnim;
@synthesize walkingAnim;

static cpBool begin(cpArbiter *arb, cpSpace *space, void *ignore) {
    CP_ARBITER_GET_SHAPES(arb, ninjaShape, groundShape);
    CPNinja *ninja = (CPNinja *)ninjaShape->data;
    cpVect n = cpArbiterGetNormal(arb, 0);
    if (n.y < 0.0f) {
        cpArray *groundShapes = ninja.groundShapes;
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
    CP_ARBITER_GET_SHAPES(arb, ninjaShape, groundShape);
    CPNinja *ninja = (CPNinja *)ninjaShape->data;
    cpArrayDeleteObj(ninja.groundShapes, groundShape);
}

-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody {
    if ((self = [super initWithSpriteFrameName:@"Ninja1.png"])) {
        CGSize size = CGSizeMake(30, 30);
        self.anchorPoint = ccp(0.5, 20/self.contentSize.height);
        NSLog(@"%f, %f", self.contentSize.width, self.contentSize.height);
        [self addBoxBodyAndShapeWithLocation:location size:size space:theSpace mass:1.0 e:0.0 u:1.0 collisionType:kCollisionTypeNinja canRotate:FALSE];
        groundShapes = cpArrayNew(0);
        cpSpaceAddCollisionHandler(space, kCollisionTypeNinja, kCollisionTypeGround, begin, preSolve, NULL, separate, NULL);
        cpConstraint *constraint = cpRotaryLimitJointNew(groundBody, body, CC_DEGREES_TO_RADIANS(0), CC_DEGREES_TO_RADIANS(0));
        cpSpaceAddConstraint(space, constraint);
        [self initAnimations];
    }
    return self;
}

-(void)initAnimations{
    NSMutableArray *attackFrames = [[[NSMutableArray alloc] initWithCapacity:4] retain];
    for (int i=1; i<=4; ++i) {
        [attackFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"NinjaAttack%d.png", i]]];
    }
    self.attackAnim = [CCAnimation animationWithFrames:attackFrames delay:0.1f];
    
    NSMutableArray *walkFrames = [[[NSMutableArray alloc] initWithCapacity:4] retain];
    for (int i=1; i<=4; ++i) {
        [walkFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"NinjaWalking%d.png", i]]];
    }
    self.walkingAnim = [CCAnimation animationWithFrames:walkFrames delay:0.25f];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (groundShapes->num > 0) {
        jumpStartTime = CACurrentMediaTime();
    }
    firstTouch = [touch locationInView:[touch view]];
    return TRUE;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    //jumpStartTime = 0;
    secondTouch = [touch locationInView:[touch view]];
    if ((secondTouch.y - firstTouch.y) < -10.0f || (secondTouch.y - firstTouch.y) > 10.0f) {
        [self changeState:kStateAttacking];
        shouldJump = NO;
    } else {
        shouldJump = YES;
        [self changeState:kStateJumping];
    }
        
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    accelerationFraction = acceleration.y*2;
    if (accelerationFraction < -1) {
        accelerationFraction = -1;
    } else if (accelerationFraction > 1) {
        accelerationFraction = 1;
    }
    
    if ([[CCDirector sharedDirector] deviceOrientation] == UIDeviceOrientationLandscapeLeft) {
        accelerationFraction *= -1;
    }
}

-(void) changeState:(CharacterStates)newState{
    [self stopAllActions];
    id action = nil;
    [self setCharacterState:newState];
    switch (newState) {
        case kStateWalking:
            action =  [CCAnimate actionWithAnimation:walkingAnim restoreOriginalFrame:NO];
            break;
        case kStateIdle:
            [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Ninja1.png"]];
            break;
        case kStateAttacking:
            action = [CCAnimate actionWithAnimation:attackAnim restoreOriginalFrame:YES];
            NSLog(@"ATTACCCKKKINNGGG!!! ");
            break;
        case kStateJumping:
            NSLog(@"Jump");
        default:
            break;
    }
    if (action != nil) {
        [self runAction:action];
    }
}


-(CGRect)adjustedBoundingBox {
    CGRect ninjaBoundingBox = [self boundingBox];
    float xOffset;
    float xCropAmount = ninjaBoundingBox.size.width * 0.5482f;
    float yCropAmount = ninjaBoundingBox.size.height * 0.095f;
    if ([self flipX] == YES){
        xOffset = ninjaBoundingBox.size.width * 0.1566f;
    }
    else {
        xOffset = ninjaBoundingBox.size.width * 0.4217f;
    }
    ninjaBoundingBox = 
    CGRectMake(ninjaBoundingBox.origin.x + xOffset, ninjaBoundingBox.origin.y, ninjaBoundingBox.size.width-xCropAmount, ninjaBoundingBox.size.height - yCropAmount);
    return ninjaBoundingBox;
}


-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
    
    CGPoint oldPosition = self.position;
    [super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
    float jumpFactor = 200.0;
    CGPoint newVel = body->v;
    if (characterState == kStateAttacking && [self numberOfRunningActions] == 0) {
        [self changeState:kStateIdle];
    }
    
    if (groundShapes->num == 0) {
        newVel = ccp(jumpFactor*accelerationFraction, body->v.y);
    }
    
    double timeJumping = CACurrentMediaTime() - jumpStartTime;
    if (jumpStartTime != 0 && shouldJump==YES) {
        newVel.y = jumpFactor*2;
        shouldJump = NO;
        jumpStartTime = 0;
    }
    cpBodySetVel(body, newVel);
    
    if (groundShapes->num > 0) {
        if (ABS(accelerationFraction) < 0.05) {
            accelerationFraction = 0;
            shape->surface_v = ccp(0, 0);
        } else {
            float maxSpeed = 200.0f;
            shape->surface_v = ccp(-maxSpeed*accelerationFraction, 0);
            cpBodyActivate(body);
        }
    } else {
        shape->surface_v = cpvzero;
    }
    
    float margin = 20;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    if (body->p.x < margin) {
        cpBodySetPos(body, ccp(margin, body->p.y));
    }
    
    if (body->p.x > 1600 - margin) {
        cpBodySetPos(body, ccp(1600 - margin, body->p.y));
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

@end
