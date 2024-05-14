 #import "public/MSHFDotView.h"

@implementation MSHFDotView

- (instancetype)initWithFrame:(CGRect)frame barSpacing:(CGFloat)barSpacing {
  self = [self initWithFrame:frame];

  if (self) {
    self.barSpacing = 10;
  }

  return self;
}

- (void)initializeWaveLayers {
  if (self.siriEnabled) {
    redDots = [[CALayer alloc] init];
    greenDots = [[CALayer alloc] init];
    blueDots = [[CALayer alloc] init];
    
    [self.layer addSublayer:redDots];
    [self.layer addSublayer:greenDots];
    [self.layer addSublayer:blueDots];
    
    redDots.zPosition = 0;
    greenDots.zPosition = -1;
    blueDots.zPosition = -2;
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
  CGFloat width = ((self.frame.size.width - self.barSpacing) / (CGFloat)self.numberOfPoints);
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
      layer.cornerRadius = barWidth / 2.0;
      layer.frame = CGRectMake(i * width + self.barSpacing, 0, barWidth, barWidth);
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor;
      }
      [self.layer addSublayer:layer];
    }
  } else {
    redDots.sublayers = nil;
    greenDots.sublayers = nil;
    blueDots.sublayers = nil;
    
    for (int r = 0; r < self.numberOfPoints; r++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.frame = CGRectMake(r * width + self.barSpacing, 0, barWidth, barWidth);
      layer.cornerRadius = barWidth / 2.0;
      if (self.waveColor) {
        layer.backgroundColor = self.waveColor;
      }
      [redDots addSublayer:layer];
    }
    
    for (int g = 0; g < self.numberOfPoints; g++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.frame = CGRectMake(g * width + self.barSpacing, 0, barWidth, barWidth);
      layer.cornerRadius = barWidth / 2.0;
      if (self.subwaveColor) {
        layer.backgroundColor = self.subwaveColor;
      }
      [greenDots addSublayer:layer];
    }
    
    for (int b = 0; b < self.numberOfPoints; b++) {
      CALayer *layer = [[CALayer alloc] init];
      layer.frame = CGRectMake(b * width + self.barSpacing, 0, barWidth, barWidth);
      layer.cornerRadius = barWidth / 2.0;
      if (self.subSubwaveColor) {
        layer.backgroundColor = self.subSubwaveColor;
      }
      [blueDots addSublayer:layer];
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
  if (!redDots) {
    [self initializeWaveLayers];
  }
  CGColorRelease(self.waveColor);
  CGColorRelease(self.subwaveColor);
  CGColorRelease(self.subSubwaveColor);
  self.waveColor = CGColorRetain(waveColor);
  self.subwaveColor = CGColorRetain(subwaveColor);
  self.subSubwaveColor = CGColorRetain(subSubwaveColor);

  redDots.compositingFilter = @"screenBlendMode";
  greenDots.compositingFilter = @"screenBlendMode";
  blueDots.compositingFilter = @"screenBlendMode";
  
  for (CALayer *layer in [redDots sublayers]) {
    layer.backgroundColor = waveColor;
  }
  for (CALayer *layer in [greenDots sublayers]) {
    layer.backgroundColor = subwaveColor;
  }
  for (CALayer *layer in [blueDots sublayers]) {
    layer.backgroundColor = subSubwaveColor;
  }
}

- (void)redraw {
  [super redraw];

  CGFloat width = (self.frame.size.width - self.barSpacing) / (CGFloat)self.numberOfPoints;
  CGFloat barWidth = MAX(width - self.barSpacing, 1) / 2 + self.barSpacing;

  if (!self.siriEnabled) {
    int i = 0;
    for (CALayer *layer in [self.layer sublayers]) {
      layer.position = CGPointMake(i * width + barWidth, self.points[i].y);
      i++;
    }
  } else {
    int r = 0;
    for (CALayer *layer in [redDots sublayers]) {
      layer.position = CGPointMake(r * width + barWidth, self.points[r].y);
      r++;
    }
    
    int g = 0;
    for (CALayer *layer in [greenDots sublayers]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        layer.position = CGPointMake(g * width + barWidth, self.points[g].y);
      });
      g++;
    }
    
    int b = 0;
    for (CALayer *layer in [blueDots sublayers]) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        layer.position = CGPointMake(b * width + barWidth, self.points[b].y);
      });
      b++;
    }
  }
}

@end
