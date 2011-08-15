KRLiveStream
============

KRLiveStream connects seamlessly to your Redis Pub/Sub Server from your iOS or Mac app and patiently listens for messages sent to it. It manages the socket connection to Redis using [CocoaAsyncSocket][cas] in the background, always listening for new messages sent to it without disconnecting (unless your app terminates, enters the background, times out on the server, or you specifically disconnect). All messages need to be sent in JSON and will be parsed using JSONKit as an NSDictionary.

We built KRLiveStream for [Keyhole.IO][website] as we use Redis as our Pub/Sub server. If you're looking for a cloud-based key-value pair store with live data streaming and messaging, look no further than [Keyhole.IO][website]!
  
_Dependencies_:  
1. [JSONKit][jsonkit]  
2. [CocoaAsyncSocket][cas]  
(both are included in the KRLiveStream directory).  

Getting Started
---------------

Just drag the **KRLiveStream** directory from Finder into your Xcode project and then include it in one of your headers.  

Examples
--------

**Add the protocol to a controller**  
`@interface RootViewController : UITableViewController <KRLiveStreamDelegate>`

**Connect and listen for messages**  
`[[KRLiveStream sharedKRLiveStream] connectToServer:@"keyhole.io" port:[NSNumber numberWithInt:6379] channel:@"my_spiffy_channel" delegate:self];`  
You can also use this method to change from one channel to another. It'll automatically unsubscribe you from the previous channel before connecting to the new channel.  

**Listen for connection callback** (_optional_)  
`- (void)liveStreamConnected {  
    NSLog(@"Server connected");  
}`

**Get a message and react** (_required_)  
`- (void)liveStreamMessageReceived:(NSDictionary *)message {  
    NSLog(@"Received message: %@", message);  
}`

**Disconnect from server**  
`- (IBAction)disconnect {  
    [[KRLiveStream] sharedKRLiveStream] disconnectFromServer];    
}`

**Disconnection callback** (_optional_)  
`- (void)liveStreamDisconnected {  
    NSLog(@"Server disconnected");  
}`  


To do
-----

1. Implement support for multiple connections. Current implementation only allows for a connection to one Redis Pub/Sub channel at a time.  
2. Tests (OMG, so bad, I know, but I will get around to doing this).  

---

Feel free to fork, fix, add more features and submit a pull request!

**Kishyr Ramdial**  
[Keyhole.IO][website]

[website]: http://keyhole.io
[cas]: http://code.google.com/p/cocoaasyncsocket/
[jsonkit]: https://github.com/johnezang/JSONKit