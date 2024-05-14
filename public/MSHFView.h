#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MSHFAudioSource.h"
#import "MSHFAudioProcessingDelegate.h"
#import "MSHFAudioProcessing.h"

#ifdef THEOS_PACKAGE_INSTALL_PREFIX
#define MSHFPrefsFile                                             \
  @"/var/jb/var/mobile/Library/Preferences/com.ryannair05.mitsuhaforever.plist"
#else
#define MSHFPrefsFile                                             \
  @"/var/mobile/Library/Preferences/com.ryannair05.mitsuhaforever.plist"
#endif

@interface MSHFView : UIView <MSHFAudioDelegate, MSHFAudioProcessingDelegate> {
  long long silentSince;
  bool MSHFHidden;
}

@property(nonatomic, assign) BOOL disableBatterySaver;
@property(nonatomic, assign) NSInteger numberOfPoints;

@property(nonatomic, assign) float gain;
@property(nonatomic, assign) float limiter;

@property(nonatomic, assign) CGFloat waveOffset;
@property(nonatomic, assign) CGFloat sensitivity;

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) CGPoint *points;

@property(nonatomic, assign) BOOL siriEnabled;

@property(nonatomic, assign) CGColorRef waveColor;
@property(nonatomic, assign) CGColorRef subwaveColor;
@property(nonatomic, assign) CGColorRef subSubwaveColor;

@property(nonatomic, retain) MSHFAudioSource *audioSource;

@property(nonatomic, retain) MSHFAudioProcessing *audioProcessing;

- (void)updateWaveColor:(CGColorRef)waveColor
           subwaveColor:(CGColorRef)subwaveColor;

- (void)updateWaveColor:(CGColorRef)waveColor
           subwaveColor:(CGColorRef)subwaveColor
        subSubwaveColor:(CGColorRef)subSubwaveColor;

- (void)start;
- (void)stop;

- (void)configureDisplayLink;

- (void)initializeWaveLayers;
- (void)resetWaveLayers;
- (void)redraw;

- (void)updateBuffer:(float *)bufferData withLength:(int)length;

- (void)setSampleData:(float *)data length:(int)length;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame
                  audioSource:(MSHFAudioSource *)audioSource;

@end

@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)isPlaying; 
@end
