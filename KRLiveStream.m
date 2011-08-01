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
#import "ObjCHiredis.h"
#import "SynthesizeSingleton.h"
#import "JSONKit.h"

@implementation KRLiveStream

SYNTHESIZE_SINGLETON_FOR_CLASS(KRLiveStream);

@synthesize serverHost = _serverHost, serverPort = _serverPort, channelName = _channelName;
@synthesize delegate = _delegate, que = _que;
@synthesize openConnection = _openConnection;

- (id)init
{
  self = [super init];
  if (self) {
    self.que = dispatch_queue_create("com.kishyr.realtime.redis", NULL);
  }
  
  return self;
}

- (void)connectToServer:(NSString *)host port:(NSNumber *)port channel:(NSString *)channel delegate:(id<KRLiveStreamDelegate>)theDelegate {
  self.serverHost = host;
  self.serverPort = port;
  self.channelName = channel;
  self.delegate = theDelegate;
  
  
  dispatch_async(self.que, ^{  
    self.openConnection = YES;
    ObjCHiredis * redis = [ObjCHiredis redis:self.serverHost on:self.serverPort];        
    while (self.openConnection) {
      NSLog(@"KRLiveStream Connected!");
      [redis command:[NSString stringWithFormat:@"SUBSCRIBE %@", self.channelName]];
      NSArray *retVal = [redis getReply];
      if (![[retVal objectAtIndex:2] isKindOfClass:[NSNumber class]]) {
        NSString *message = [NSString stringWithFormat: @"%@", [[retVal objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
        NSDictionary *returnedData = [[message objectFromJSONString] retain];
        dispatch_async(dispatch_get_main_queue(), ^{
          if([self.delegate respondsToSelector:@selector(liveStreamMessageReceived:)]) {
            [self.delegate liveStreamMessageReceived:returnedData];
          }
        });           
        [returnedData release];
      }
    }        
  });
}

- (void)disconnectFromServer {
  dispatch_async(self.que, ^{  
    self.openConnection = NO;
  });
}

- (void)disconnectFromChannel {
  dispatch_async(self.que, ^{  
    ObjCHiredis * redis = [ObjCHiredis redis:self.serverHost on:self.serverPort];        
    [redis command:[NSString stringWithFormat:@"UNSUBSCRIBE %@", self.channelName]];
    if([self.delegate respondsToSelector:@selector(streamDisconnected)]) {
      [self.delegate streamDisconnected];
    }
  });
}


@end
