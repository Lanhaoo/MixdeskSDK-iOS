#import <Foundation/Foundation.h>
#import "MIXDESK_FBFontSymbol.h"
#import <UIKit/UIKit.h>

@interface MIXDESK_FBLCDFont : NSObject
+ (void)drawSymbol:(FBFontSymbolType)symbol
        edgeLength:(CGFloat)edgeLength
         lineWidth:(CGFloat)lineWidth
        startPoint:(CGPoint)startPoint
         inContext:(CGContextRef)ctx;
@end

