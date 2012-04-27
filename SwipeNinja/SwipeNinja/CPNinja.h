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

@end
