#import "MSHFView.h"

@interface MSHFBarView : MSHFView {
    CALayer *redBars;
    CALayer *greenBars;
    CALayer *blueBars;
}

- (instancetype)initWithFrame:(CGRect)frame barSpacing:(CGFloat)barSpacing barCornerRadius:(CGFloat)barCornerRadius;

@property(nonatomic, assign) CGFloat barCornerRadius;
@property(nonatomic, assign) CGFloat barSpacing;

@end
