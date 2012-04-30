//
//  Goal.h
//  SwipeNinja
//
//  Created by John on 4/30/12.
//  Copyright (c) 2012 University of Miami. All rights reserved.
//

#import "CPSprite.h"

@interface Goal : CPSprite {
    cpArray *groundShapes;
    CGPoint initialPosition;
}


-(id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace groundBody:(cpBody *)groundBody;

@property (readonly) cpArray *groundShapes;

@end
