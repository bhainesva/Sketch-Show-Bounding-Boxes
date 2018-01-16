//
//  SketchWire.m
//  SketchWire
//
//  Created by Pravdomil Toman on 15/01/2018.
//  Copyright © 2018 Pravdomil Toman. All rights reserved.
//

#import "SketchWire.h"
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation SketchWire
+ (bool)install
{
    return true;
}

+ (bool)toggle
{
    SEL renderLayerUncached = @selector(renderLayerUncached:ignoreDrawingArea:context:);
    if(![self swizzle:@"MSTextRendererCG" from:renderLayerUncached to:@selector(textRenderer:ignoreDrawingArea:context:)]) {
        return false;
    }
    if(![self swizzle:@"MSShapeRendererCG" from:renderLayerUncached to:@selector(shapeRenderer:ignoreDrawingArea:context:)]) {
        return false;
    }
    if(![self swizzle:@"MSBitmapRendererCG" from:renderLayerUncached to:@selector(bitmapRenderer:ignoreDrawingArea:context:)]) {
        return false;
    }
    
    SEL shouldDrawBackground = @selector(shouldDrawBackgroundInContext:isDrawingAsSymbolInstance:);
    if(![self swizzle:@"MSImmutableArtboardGroup" from:shouldDrawBackground to:@selector(shouldDrawArtboardGroupBackground:isDrawingAsSymbolInstance:)]) {
        return false;
    }
    if(![self swizzle:@"MSImmutableSymbolMaster" from:shouldDrawBackground to:@selector(shouldDrawSymbolMasterBackground:isDrawingAsSymbolInstance:)]) {
        return false;
    }
    
    return true;
}

+ (bool)swizzle:(NSString*)className from:(SEL)from to:(SEL)to
{
    Class class = NSClassFromString(className);
    if (!class) {
        return false;
    }
    
    Method original = class_getInstanceMethod(class, from);
    if (!original) {
        return false;
    }
    
    Method swizzled = class_getInstanceMethod([self class], to);
    if (!swizzled) {
        return false;
    }
    
    method_exchangeImplementations(original, swizzled);
    return true;
}

+ (void)renderPlaceholder:(MSImmutableLayer*)layer ignoreDrawingArea:(BOOL)ignoreDrawingArea context:(MSRenderingContext*)context
{
    struct CGContext* c = context.contextRef;
    
    // stroke width
    CGFloat strokeWidth = 0.5;
    CGContextSetLineWidth(c, strokeWidth);
    
    // rect
    struct CGRect rect = NSInsetRect(layer.rect, strokeWidth / 2, strokeWidth / 2);
    CGContextStrokeRect(c, rect);
    
    // line from left top 2 right bottom
    const CGPoint points1[] = {
        CGPointMake(rect.origin.x                  , rect.origin.y),
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
    };
    CGContextAddLines(c, points1, sizeof(points1)/ sizeof(points1[0]));
    CGContextStrokePath(c);
    
    // line from right top 2 bottom left
    const CGPoint points2[] = {
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y),
        CGPointMake(rect.origin.x                  , rect.origin.y + rect.size.height),
    };
    CGContextAddLines(c, points2, sizeof(points2)/ sizeof(points2[0]));
    CGContextStrokePath(c);
}

- (bool)shouldDrawArtboardGroupBackground:(id)arg1 isDrawingAsSymbolInstance:(BOOL)arg2
{
    return false;
}

- (bool)shouldDrawSymbolMasterBackground:(id)arg1 isDrawingAsSymbolInstance:(BOOL)arg2
{
    return false;
}

- (void)textRenderer:(MSImmutableLayer*)layer ignoreDrawingArea:(BOOL)ignoreDrawingArea context:(MSRenderingContext*)context
{
    [SketchWire renderPlaceholder:layer ignoreDrawingArea:ignoreDrawingArea context:context];
}

- (void)shapeRenderer:(MSImmutableLayer*)layer ignoreDrawingArea:(BOOL)ignoreDrawingArea context:(MSRenderingContext*)context
{
    [SketchWire renderPlaceholder:layer ignoreDrawingArea:ignoreDrawingArea context:context];
}

- (void)bitmapRenderer:(MSImmutableLayer*)layer ignoreDrawingArea:(BOOL)ignoreDrawingArea context:(MSRenderingContext*)context
{
    [SketchWire renderPlaceholder:layer ignoreDrawingArea:ignoreDrawingArea context:context];
}
@end

