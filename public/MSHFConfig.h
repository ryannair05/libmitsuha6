#import "MSHFBarView.h"
#import "MSHFDotView.h"
#import "MSHFJelloView.h"
#import "MSHFLineView.h"
#import "MSHFSiriView.h"

@interface MSHFConfig : NSObject

@property (nonatomic) BOOL enabled;
@property (nonatomic) NSInteger style;
@property (nonatomic) NSInteger colorMode;
@property (nonatomic) CGFloat waveOffset;
@property (nonatomic) CGFloat waveOffsetOffset;

@property (nonatomic, strong) MSHFView * view;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dict;

- (instancetype)initWithAppName:(NSString *)name;

- (void)colorizeView:(UIImage *)image;
- (MSHFView *)initializeViewWithFrame:(CGRect)frame;

- (void)reload;

@end
