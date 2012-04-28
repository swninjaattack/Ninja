//
//  Robot.h
//  SwipeNinja
//
//  Created by John on 4/26/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "CPSprite.h"

@interface Robot : CPSprite{
    CCAnimation *walkingAnim;
    CPSprite *ninja;
    cpArray *groundShapes;
    double movingStartTime;
    float accelerationFraction; //not sure if this is allowed?
    float lastFlip;
}

-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody;
- (void) removeBody;

@property (readonly) cpArray *groundShapes;
@property (nonatomic, retain) CCAnimation *walkingAnim;

@end
