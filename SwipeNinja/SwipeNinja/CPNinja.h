//
//  CPNinja.h
//  SwipeNinja
//
//  Created by Ryan Lesko on 4/15/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "CPSprite.h"

@interface CPNinja : CPSprite {
    cpArray *groundShapes;
    CCAnimation *attackAnim;
    CCAnimation *walkingAnim;
    CCAnimation *jumpAnim;
    CCAnimation *inAirAnim;
    CCAnimation *landAnim;
    CPSprite *robot;
    CPSprite *goal;
    double jumpStartTime;
    float accelerationFraction;
    float lastFlip;
    CGPoint firstTouch;
    CGPoint secondTouch;
    BOOL shouldJump;
}

-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody;
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

@property (readonly) cpArray *groundShapes;
@property (nonatomic, retain) CCAnimation *attackAnim;
@property (nonatomic, retain) CCAnimation *walkingAnim;
@property (nonatomic, retain) CCAnimation *jumpAnim;
@property (nonatomic, retain) CCAnimation *inAirAnim;
@property (nonatomic, retain) CCAnimation *landAnim;

@end
