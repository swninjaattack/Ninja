#import "CPPivotPlatform.h"

@implementation CPPivotPlatform

- (id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace 
            groundBody:(cpBody *)groundBody {    
    if ((self = [super 
                 initWithSpriteFrameName:@"platform_pivot.png"])) {        
        [self addBoxBodyAndShapeWithLocation:location 
                                        size:self.contentSize space:theSpace mass:10.0 e:0.2 u:1.0 
                               collisionType:kCollisionTypeGround canRotate:TRUE];            
        
        // 1
        cpConstraint *c1 = cpPivotJointNew(groundBody, body, body->p);
        cpSpaceAddConstraint(space, c1);
        
        // 2
        cpConstraint *c2 = cpDampedRotarySpringNew(groundBody, body, 0, 
                                                   60000.0, 100.0);
        cpSpaceAddConstraint(space, c2);
        
        // 3
        cpConstraint *c3 = cpRotaryLimitJointNew(groundBody, body, 
                                                 CC_DEGREES_TO_RADIANS(-30), CC_DEGREES_TO_RADIANS(30));
        cpSpaceAddConstraint(space, c3);        
    }
    return self;    
}

@end
