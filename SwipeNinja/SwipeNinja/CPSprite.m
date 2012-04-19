#import "CPSprite.h"

@implementation CPSprite

-(void)updateStateWithDeltaTime:(ccTime)deltaTime 
           andListOfGameObjects:(CCArray*)listOfGameObjects {    
    self.position = ccp(body->p.x, body->p.y);
    self.rotation = CC_RADIANS_TO_DEGREES( -body->a );
}

- (void)addBoxBodyAndShapeWithLocation:(CGPoint)location 
                                  size:(CGSize)size 
                                 space:(cpSpace *)theSpace 
                                  mass:(cpFloat)mass 
                                     e:(cpFloat)e 
                                     u:(cpFloat)u 
                         collisionType:(cpCollisionType)collisionType 
                             canRotate:(BOOL)canRotate {
    
    space = theSpace;
    
    float moment = INFINITY;
    if (canRotate) {
        moment = cpMomentForBox(mass, size.width, size.height);
    }
    
    body = cpBodyNew(mass, moment);
    body->p = location;
    cpSpaceAddBody(space, body);
    
    shape = cpBoxShapeNew(body, size.width, size.height);
    shape->e = e;
    shape->u = u;
    shape->collision_type = collisionType;
    shape->data = self;
    cpSpaceAddShape(space, shape);    
}

@end
