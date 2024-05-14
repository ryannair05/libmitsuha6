#import "MSHFView.h"

@interface MSHFDotView : MSHFView {
    CALayer *redDots;
    CALayer *greenDots;
    CALayer *blueDots;
}

- (instancetype)initWithFrame:(CGRect)frame barSpacing:(CGFloat)barSpacing;

@property(nonatomic, assign) CGFloat barSpacing;

@end
