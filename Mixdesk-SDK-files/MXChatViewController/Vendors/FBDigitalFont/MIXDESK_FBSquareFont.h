#import <Foundation/Foundation.h>
#import "MIXDESK_FBFontSymbol.h"
#import <UIKit/UIKit.h>

@interface MIXDESK_FBSquareFont : NSObject
+ (void)drawSymbol:(FBFontSymbolType)symbol
horizontalEdgeLength:(CGFloat)horizontalEdgeLength
  verticalEdgeLength:(CGFloat)verticalEdgeLength
          startPoint:(CGPoint)startPoint
           inContext:(CGContextRef)ctx;
@end
