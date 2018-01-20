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

static bool active = false;
static bool crossActive = false;

@implementation SketchWire
+ (bool)install
{
    if(![self replaceRenderer:@"MSTextRendererCG"]) {
        return false;
    }
    if(![self replaceRenderer:@"MSShapeRendererCG"]) {
        return false;
    }
    if(![self replaceRenderer:@"MSBitmapRendererCG"]) {
        return false;
    }
    
    return true;
}

+ (void)toggle
{
    active = !active;
}

+ (void)toggleCross
{
    crossActive = !crossActive;
}

+ (bool)replaceRenderer:(NSString*)className
{
    Class class = NSClassFromString(className);
    if (!class) {
        return false;
    }
    
    SEL from = @selector(renderLayerUncached:ignoreDrawingArea:context:);
    Method original = class_getInstanceMethod(class, from);
    if (!original) {
        return false;
    }
    
    __block IMP originalImp = NULL;
    IMP replacement = imp_implementationWithBlock(^void (id _self, id layer, BOOL ignoreDrawingArea, id context) {
        // original render
        if(originalImp) {
            ((void(*)(id, SEL, id, BOOL, id))originalImp)(_self, _cmd, layer, ignoreDrawingArea, context);
        }
        
        // render placeholder
        if (active) {
            [SketchWire renderPlaceholder:layer ignoreDrawingArea:ignoreDrawingArea context:context];
        }
    });
    
    originalImp = class_replaceMethod(class, from, replacement, method_getTypeEncoding(original));
    
    if(!originalImp) {
        return false;
    }
    
    return true;
}

#define NSColorFromRGB(rgbValue) [NSColor colorWithCalibratedRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

+ (void)renderPlaceholder:(MSImmutableLayer*)layer ignoreDrawingArea:(BOOL)ignoreDrawingArea context:(MSRenderingContext*)context
{
    struct CGContext* c = context.contextRef;
    
    // stroke width
    CGFloat strokeWidth = 0.5;
    CGContextSetStrokeColor(c, CGColorGetComponents([NSColorFromRGB(0x44C0FF) CGColor]));
    CGContextSetLineWidth(c, strokeWidth);
    
    // rect
    struct CGRect rect = NSInsetRect(layer.rect, strokeWidth / 2, strokeWidth / 2);
    CGContextStrokeRect(c, rect);
    
    // optional cross
    if (crossActive) {
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
}
@end

