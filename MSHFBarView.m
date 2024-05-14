#import "public/MSHFBarView.h"

@implementation MSHFBarView

- (instancetype)initWithFrame:(CGRect)frame barSpacing:(CGFloat)spacing barCornerRadius:(CGFloat)cornerRadius {
    self = [self initWithFrame:frame];
    
    if (self) {
        self.barSpacing = spacing;
        self.barCornerRadius = cornerRadius;
    }
    
    return self;
}

- (void)initializeWaveLayers {
    if (self.siriEnabled) {
        redBars = [[CALayer alloc] init];
        greenBars = [[CALayer alloc] init];
        blueBars = [[CALayer alloc] init];
        
        [self.layer addSublayer:redBars];
        [self.layer addSublayer:greenBars];
        [self.layer addSublayer:blueBars];
        
        redBars.zPosition = 0;
        greenBars.zPosition = -1;
        blueBars.zPosition = -2;
    }
    [self resetWaveLayers];
    [self configureDisplayLink];
}

- (void)setNumberOfPoints:(NSInteger)numberOfPoints {
    [super setNumberOfPoints:numberOfPoints];
    [self resetWaveLayers];
}

- (void)setBounds:(CGRect)bounds {
    if (CGRectGetWidth(self.bounds) != CGRectGetWidth(bounds)) {
        [super setBounds:bounds];
        [self resetWaveLayers];
    } else {
        [super setBounds:bounds];
    }
}

- (void)resetWaveLayers {
    if (self.points == NULL) {
        return;
    }
    CGFloat width = ((self.frame.size.width - self.barSpacing) /
                     (CGFloat)self.numberOfPoints);
    CGFloat barWidth = width - self.barSpacing;
    if (width <= 0)
        width = 1;
    if (barWidth <= 0)
        barWidth = 1;
    
    if (!self.siriEnabled) {
        self.layer.sublayers = nil;
        
        for (int i = 0; i < self.numberOfPoints; i++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.opaque = YES;
            layer.cornerRadius = self.barCornerRadius;
            layer.frame = CGRectMake(i * width + self.barSpacing, 0, barWidth,
                                     self.frame.size.height);
            if (self.waveColor) {
                layer.backgroundColor = self.waveColor;
            }
            [self.layer addSublayer:layer];
        }
    } else {
        redBars.sublayers = nil;
        greenBars.sublayers = nil;
        blueBars.sublayers = nil;
        
        for (int r = 0; r < self.numberOfPoints; r++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.cornerRadius = self.barCornerRadius;
            layer.frame = CGRectMake(r * width + self.barSpacing, 0, barWidth,
                                     self.frame.size.height);
            if (self.waveColor) {
                layer.backgroundColor = self.waveColor;
            }
            [redBars addSublayer:layer];
        }
        
        for (int g = 0; g < self.numberOfPoints; g++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.cornerRadius = self.barCornerRadius;
            layer.frame = CGRectMake(g * width + self.barSpacing, 0, barWidth,
                                     self.frame.size.height);
            if (self.subwaveColor) {
                layer.backgroundColor = self.subwaveColor;
            }
            [greenBars addSublayer:layer];
        }
        
        for (int b = 0; b < self.numberOfPoints; b++) {
            CALayer *layer = [[CALayer alloc] init];
            layer.cornerRadius = self.barCornerRadius;
            layer.frame = CGRectMake(b * width + self.barSpacing, 0, barWidth,
                                     self.frame.size.height);
            if (self.subSubwaveColor) {
                layer.backgroundColor = self.subSubwaveColor;
            }
            [blueBars addSublayer:layer];
        }
    }
}

- (void)updateWaveColor:(CGColorRef)waveColor subwaveColor:(CGColorRef)subwaveColor {
    CGColorRelease(self.waveColor);
    self.waveColor = CGColorRetain(waveColor);
    for (CALayer *layer in [self.layer sublayers]) {
        layer.backgroundColor = waveColor;
    }
}

- (void)updateWaveColor:(CGColorRef)waveColor subwaveColor:(CGColorRef)subwaveColor subSubwaveColor:(CGColorRef)subSubwaveColor {
  if (!redBars) {
    [self initializeWaveLayers];
  }
  CGColorRelease(self.waveColor);
  CGColorRelease(self.subwaveColor);
  CGColorRelease(self.subSubwaveColor);
  
  self.waveColor = CGColorRetain(waveColor);
  self.subwaveColor = CGColorRetain(subwaveColor);
  self.subSubwaveColor = CGColorRetain(subSubwaveColor);

  redBars.compositingFilter = @"screenBlendMode";
  greenBars.compositingFilter = @"screenBlendMode";
  blueBars.compositingFilter = @"screenBlendMode";
  
  for (CALayer *layer in [redBars sublayers]) {
    layer.backgroundColor = waveColor;
  }
  for (CALayer *layer in [greenBars sublayers]) {
    layer.backgroundColor = subwaveColor;
  }
  for (CALayer *layer in [blueBars sublayers]) {
    layer.backgroundColor = subSubwaveColor;
  }
}

- (void)redraw {
    [super redraw];
    
    int pointCount = self.numberOfPoints;
    
    CGFloat width = ((self.frame.size.width - self.barSpacing) /
                     (CGFloat)pointCount);
    CGFloat barWidth = width - self.barSpacing;
    if (width <= 0)
        width = 1;
    if (barWidth <= 0)
        barWidth = 1;
    
    if (!self.siriEnabled) {
        NSArray *sublayers = [self.layer sublayers];
        for (int i = 0; i < pointCount; i++) {
            CALayer *layer = sublayers[i];
            CGFloat yPosition = self.points[i].y;
            if (isnan(yPosition))
                yPosition = 0;
            CGFloat barHeight = self.frame.size.height - yPosition;
            if (barHeight <= 0) barHeight = 1;
            
            layer.frame = CGRectMake(i * width + self.barSpacing, yPosition, barWidth, barHeight);
        }
    } else {
        NSArray *redSublayers = [redBars sublayers];
        for (int r = 0; r < pointCount; r++) {
            CALayer *layer = redSublayers[r];
            if (isnan(self.points[r].y)) {
                self.points[r].y = 0;
            }
            
            CGFloat barHeight = self.frame.size.height - self.points[r].y;
            if (barHeight <= 0)
                barHeight = 1;
            
            layer.frame = CGRectMake(r * width + self.barSpacing, self.points[r].y, barWidth, barHeight);
        }
        
        NSArray *greenSublayers = [greenBars sublayers];
        for (int g = 0; g < pointCount; g++) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CALayer *layer = greenSublayers[g];
                CGFloat barHeight = self.frame.size.height - self.points[g].y;
                if (barHeight <= 0)
                    barHeight = 1;
                
                layer.frame = CGRectMake(g * width + self.barSpacing, self.points[g].y, barWidth, barHeight);
            });
        }
        
        NSArray *blueSublayers = [blueBars sublayers];
        for (int b = 0; b < pointCount; b++) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CALayer *layer = blueSublayers[b];
                CGFloat barHeight = self.frame.size.height - self.points[b].y;
                if (barHeight <= 0)
                    barHeight = 1;
                
                layer.frame = CGRectMake(b * width + self.barSpacing, self.points[b].y, barWidth, barHeight);
            });
        }
    }
}
@end
