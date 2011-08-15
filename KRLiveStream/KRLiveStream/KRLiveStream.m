//
//  KRLiveStream.m
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

#import "KRLiveStream.h"
#import "SynthesizeSingleton.h"
#import "JSONKit.h"

#define TAG_SUBSCRIBE 0
#define TAG_UNSUBSCRIBE 2
#define TAG_READ_DATA 1

@implementation KRLiveStream

SYNTHESIZE_SINGLETON_FOR_CLASS(KRLiveStream);

@synthesize serverHost = _serverHost, serverPort = _serverPort, channelName = _channelName;
@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
  }
  
  return self;
}

- (void)dealloc {
  [_serverHost release];
  [_serverPort release];
  [_channelName release];
  [_delegate release];
  [_socket release];
  [super dealloc];
}

- (void)connectToServer:(NSString *)host port:(NSNumber *)port channel:(NSString *)channel delegate:(id<KRLiveStreamDelegate>)theDelegate {
  self.serverHost = host;
  self.serverPort = port;
  self.channelName = channel;
  self.delegate = theDelegate;
  
  if (!_socket)
    _socket = [[AsyncSocket alloc] initWithDelegate:self];
  
  NSError *error = nil;
  if (![_socket isConnected]) {
    [_socket connectToHost:self.serverHost onPort:[self.serverPort intValue] error:&error];
    if (error) 
      NSLog(@"[KRLiveStream] Error: %@", [error description]);
  }
  else {
    [self unsubscribeFromCurrentChannel];
    [self subscribeToCurrentChannel];
   }
}

- (void)subscribeToCurrentChannel {
  NSData *command = [[[NSString stringWithFormat:@"SUBSCRIBE %@", self.channelName] redisString] dataUsingEncoding:NSUTF8StringEncoding];
  NSLog(@"[KRLiveStream] Connecting to %@", self.channelName);
  [_socket writeData:command withTimeout:100 tag:TAG_SUBSCRIBE];  
}

- (void)unsubscribeFromCurrentChannel {
  NSData *command = [[[NSString stringWithFormat:@"UNSUBSCRIBE %@", self.channelName] redisString] dataUsingEncoding:NSUTF8StringEncoding];
  NSLog(@"[KRLiveStream] Disconnecting from %@", self.channelName);
  [_socket writeData:command withTimeout:100 tag:TAG_UNSUBSCRIBE];  
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
  NSLog(@"[KRLiveStream] Connected");
  
  if ([self.delegate respondsToSelector:@selector(liveStreamConnected)]) 
    [self.delegate liveStreamConnected];
  
  [self subscribeToCurrentChannel];
  
  NSData *command2 = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
  [_socket readDataToData:command2 withTimeout:-1 tag:TAG_READ_DATA];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
  NSLog(@"[KRLiveStream] Disconnected");
  if ([self.delegate respondsToSelector:@selector(liveStreamDisconnected)]) 
    [self.delegate liveStreamDisconnected];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
  NSLog(@"[KRLiveStream] Wrote data with tag: %ld", tag);
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  NSLog(@"[KRLiveStream] Read partial data, only %u bytes. Tag: %ld", partialLength, tag);
}


- (void)onSocket:(AsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag {
  if (tag == 1) {
    NSString *s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    // if the first character is a "{" then let's assume it's a JSON encoded string.
    // This needs to be made more elegant at some point.
    if ([[s substringToIndex:1] isEqualToString:@"{"]) {
      if ([self.delegate respondsToSelector:@selector(liveStreamMessageReceived:)])
        [self.delegate liveStreamMessageReceived:[data objectFromJSONData]];
    }
    
    NSData *command2 = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    [_socket readDataToData:command2 withTimeout:-1 tag:TAG_READ_DATA];
  }
}

- (void)disconnectServer {
  if ([_socket isConnected])
    [_socket disconnect];  
}

@end



@implementation NSString (KRLiveStream)

- (NSString *)redisString {
  NSArray *args = [self componentsSeparatedByString:@" "];
  NSMutableArray *command = [NSMutableArray arrayWithCapacity:[args count]];
  [command addObject:[NSString stringWithFormat:@"*%d", [args count]]];
  for (NSString *s in args) {
    [command addObject:[NSString stringWithFormat:@"$%d", [s length]]];
    [command addObject:s];
  }
  
  NSString *completedCommand = [[command componentsJoinedByString:@"\r\n"] stringByAppendingString:@"\r\n"];
  
  return completedCommand;
}

@end
