#import "CPRevolvePlatform.h"

@implementation CPRevolvePlatform

- (id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace 
            groundBody:(cpBody *)groundBody {    
    if ((self = [super 
                 initWithSpriteFrameName:@"platform_revolve.png"])) {        
        [self addBoxBodyAndShapeWithLocation:location 
                                        size:self.contentSize space:theSpace mass:1.0 e:0.2 u:1.0 
                               collisionType:kCollisionTypeGround canRotate:TRUE];
        
        // 1
        cpConstraint *c1 = cpPivotJointNew(groundBody, body, body->p);
        cpSpaceAddConstraint(space, c1);
        
        // 2
        cpConstraint *c2 = cpSimpleMotorNew(groundBody, body, CC_DEGREES_TO_RADIANS(45));
        cpSpaceAddConstraint(space, c2);          
    }
    return self;    
}

@end
