KRLiveStream
============

KRLiveStream connects seamlessly to your Redis Pub/Sub Server from your iOS or Mac app and patiently listens for messages sent to it. It's essentially a wrapper for the excellent [ObjCHiredis][objcredis] and runs in the background, always listening for new messages sent to it without disconnecting. All messages need to be sent in JSON and will be parsed using JSONKit as an NSDictionary.

We built KRLiveStream for [Keyhole.IO][website] as we use Redis as our Pub/Sub server. If you're looking for a cloud-based key-value pair store with live data streaming and messaging, look no further than [Keyhole.IO][website]!
  
_Dependencies_:  
1. [JSONKit][jsonkit]  
2. [ObjCHiredis][objcredis]

Examples
--------

**Connect and listen for messages**  
`[[KRLiveStream sharedKRLiveStream] connectToServer:@"keyhole.io" port:[NSNumber numberWithInt:6379] channel:@"my-spiffy-channel" delegate:self];`

**Get a message and react**  
`- (void)liveStreamMessageReceived:(NSDictionary *)message {
  NSLog(@"Received message: %@", message);
}`

**Disconnect from server**  
`- (IBAction)disconnect {
  [[KRLiveStream] sharedKRLiveStream] disconnectFromServer];
}`

---

Feel free to fork, fix, add more features and submit a pull request!

**Kishyr Ramdial**  
[Keyhole.IO][website]

[website]: http://keyhole.io
[objcredis]: https://github.com/lp/ObjCHiredis
[jsonkit]: https://github.com/johnezang/JSONKit