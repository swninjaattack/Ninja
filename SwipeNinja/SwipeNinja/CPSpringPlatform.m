#import "CPSpringPlatform.h"

@implementation CPSpringPlatform

- (id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace 
            groundBody:(cpBody *)groundBody {    
    if ((self = [super 
                 initWithSpriteFrameName:@"platform_spring.png"])) {
        [self addBoxBodyAndShapeWithLocation:location 
                                        size:self.contentSize space:theSpace mass:1.0 e:0.2 u:1.0 
                               collisionType:kCollisionTypeGround canRotate:FALSE];
        
        // 1
        float springLength = 200;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            springLength /= 2;
        }
        cpConstraint * constraint = cpDampedSpringNew(groundBody, body, 
                                                      ccp(body->p.x, body->p.y-springLength), ccp(0,0), 
                                                      springLength, 25.0, 0.5);
        cpSpaceAddConstraint(space, constraint);
        
        // 2
        cpConstraint * c2 = cpGrooveJointNew(groundBody, body, 
                                             ccp(body->p.x, body->p.y-springLength), 
                                             ccp(body->p.x, body->p.y+springLength), ccp(0,0));
        cpSpaceAddConstraint(space, c2);        
    }
    return self;    
}

@end
