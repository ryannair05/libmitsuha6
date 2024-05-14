#import "public/MSHFAudioSource.h"

@implementation MSHFAudioSource

- (instancetype)init {
    self = [super init];
    if (self) {
        udpSocket = -1;
        _isRunning = NO;
        receiveQueue = dispatch_queue_create("com.ryannair05.libmitsuhaforever", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)start {
    if (_isRunning) {
        return;
    }

    udpSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (udpSocket < 0) {
        return;
    }

    int reuse = 1;
    if (setsockopt(udpSocket, SOL_SOCKET, SO_REUSEADDR, (char *)&reuse, sizeof(reuse)) < 0) {
        close(udpSocket);
        return;
    }

    if (setsockopt(udpSocket, SOL_SOCKET, SO_REUSEPORT, &reuse, sizeof(reuse)) < 0) {
        close(udpSocket);
        return;
    }

    struct sockaddr_in localAddr;
    memset(&localAddr, 0, sizeof(localAddr));
    localAddr.sin_family = AF_INET;
    localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    localAddr.sin_port = htons(SNAPSHOT_PORT);

    if (bind(udpSocket, (struct sockaddr *)&localAddr, sizeof(localAddr)) < 0) {
        close(udpSocket);
        return;
    }

    struct ip_mreq multicastRequest;
    multicastRequest.imr_multiaddr.s_addr = inet_addr(SNAPSHOT_ADDR);
    multicastRequest.imr_interface.s_addr = htonl(INADDR_ANY);
    if (setsockopt(udpSocket, IPPROTO_IP, IP_ADD_MEMBERSHIP, &multicastRequest, sizeof(multicastRequest)) < 0) {
        close(udpSocket);
        return;
    }

    _isRunning = YES;

    receiveSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, udpSocket, 0, receiveQueue);
    dispatch_source_set_event_handler(receiveSource, ^{
        char buffer[8192];
        ssize_t count = recvfrom(udpSocket, buffer, sizeof(buffer), 0, NULL, NULL);
        if (count <= 0) {
            [self stop];
        } else {
            [self.delegate updateBuffer:(float *)buffer withLength:count / sizeof(float)];
        }
    });
    dispatch_source_set_cancel_handler(receiveSource, ^{
        close(udpSocket);
        udpSocket = -1;
    });
    dispatch_resume(receiveSource);
}

- (void)stop {
    if (_isRunning) {
        _isRunning = NO;
        if (receiveSource) {
            dispatch_source_cancel(receiveSource);
            receiveSource = nil;
        }
        if (udpSocket >= 0) {
            close(udpSocket);
            udpSocket = -1;
        }
    }
}

@end