#import "cocos2d.h"
#import "chipmunk.h"
#import "GameCharacter.h"

@interface CPSprite : GameCharacter {
    cpBody * body;
    cpShape * shape;
    cpSpace * space;
}

- (void)addBoxBodyAndShapeWithLocation:(CGPoint)location 
                                  size:(CGSize)size 
                                 space:(cpSpace *)theSpace 
                                  mass:(cpFloat)mass 
                                     e:(cpFloat)e 
                                     u:(cpFloat)u 
                         collisionType:(cpCollisionType)collisionType 
                             canRotate:(BOOL)canRotate;

@end
