#import <Foundation/Foundation.h>

@interface SketchWire : NSObject
// MSLayerRenderer
- (void)renderLayerUncached:(id)arg1 ignoreDrawingArea:(BOOL)arg2 context:(id)arg3;
@end

@interface MSImmutableLayer : NSObject
@property(readonly, nonatomic) struct CGRect rect;
@end

@interface MSRenderingContext : NSObject
@property(nonatomic) struct CGContext *contextRef;
@end

