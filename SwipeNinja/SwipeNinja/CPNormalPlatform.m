#import "CPNormalPlatform.h"

@implementation CPNormalPlatform

-(void)updateStateWithDeltaTime:(ccTime)dt andListOfGameObjects:(CCArray*)listOfGameObjects {
    // Do nothing...
}

- (id)initWithLocation:(CGPoint)location space:(cpSpace *)theSpace 
            groundBody:(cpBody *)groundBody {    
    if ((self = [super 
                 initWithSpriteFrameName:@"platform_normal.png"])) {        
        space = theSpace;
        
        self.position = location;
        cpFloat hw = self.contentSize.width/(cpFloat)2.0;
        cpFloat hh = self.contentSize.height/(cpFloat)2.0;
        
        cpVect verts[] = {
            cpv(-hw,-hh),
            cpv(-hw, hh),
            cpv( hw, hh),
            cpv( hw,-hh),
        };
        
        shape = cpPolyShapeNew(groundBody, 4, verts, location);
        shape->e = 1.0f; 
        shape->u = 1.0f;
        shape->collision_type = kCollisionTypeGround;
        cpSpaceAddStaticShape(space, shape);           
    }
    return self;    
}

@end
