#import "MSHFAudioDelegate.h"
#import <arpa/inet.h>

#define SNAPSHOT_ADDR "239.255.0.1"
#define SNAPSHOT_PORT 44333

@interface MSHFAudioSource : NSObject {
  int udpSocket;
  dispatch_queue_t receiveQueue;
  dispatch_source_t receiveSource;
}

@property(nonatomic, assign, readonly) bool isRunning;
@property(nonatomic, retain) id<MSHFAudioDelegate> delegate;

- (void)start;
- (void)stop;

@end

