//
//  KRLiveStream.h
//  http://keyhole.io/developer
//
//  Created by Kishyr Ramdial on 2011/07/28.
//  Copyright 2011 Kishyr Ramdial. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AsyncSocket.h"

@protocol KRLiveStreamDelegate;


@interface KRLiveStream : NSObject <AsyncSocketDelegate> {
  AsyncSocket *_socket;
}

@property (nonatomic, retain) NSString *serverHost;
@property (nonatomic, retain) NSNumber *serverPort;
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, retain) id<KRLiveStreamDelegate> delegate;

+ (KRLiveStream *)sharedKRLiveStream;
- (void)connectToServer:(NSString *)host port:(NSNumber *)port channel:(NSString *)channel delegate:(id<KRLiveStreamDelegate>)theDelegate;
- (void)disconnectServer;
- (void)subscribeToCurrentChannel;
- (void)unsubscribeFromCurrentChannel;

@end


@protocol KRLiveStreamDelegate<NSObject>
- (void)liveStreamMessageReceived:(NSDictionary *)message;
@optional
- (void)liveStreamConnected;
- (void)liveStreamDisconnected;
@end


@interface NSString (KRLiveStream)

- (NSString *)redisString;

@end