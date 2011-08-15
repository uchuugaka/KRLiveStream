//
//  RootViewController.h
//  KRLiveStream
//
//  Created by Kishyr Ramdial on 2011/08/10.
//  Copyright 2011 immedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRLiveStream.h"
#import "AsyncSocket.h"

@interface RootViewController : UITableViewController <KRLiveStreamDelegate>

@property (nonatomic, retain) NSMutableArray *messages;

- (IBAction)disconnect:(id)sender;
- (IBAction)connect:(id)sender;

@end
