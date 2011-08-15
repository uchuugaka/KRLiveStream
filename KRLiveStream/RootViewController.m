//
//  RootViewController.m
//  KRLiveStream
//
//  Created by Kishyr Ramdial on 2011/08/10.
//  Copyright 2011 immedia. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

// Change these
#define REDIS_HOST @"your.redis.servers.hostname"
#define REDIS_PORT [NSNumber numberWithInt:6379]
#define REDIS_CHANNEL @"Your_Awesome_Channel"

@synthesize messages = _messages;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"KRLiveStream Demo";
  self.messages = [NSMutableArray arrayWithCapacity:1];
  [self connect:nil];
}

- (IBAction)disconnect:(id)sender {
  [[KRLiveStream sharedKRLiveStream] disconnectServer];
}

- (IBAction)connect:(id)sender {
  [[KRLiveStream sharedKRLiveStream] connectToServer:REDIS_HOST port:REDIS_PORT channel:REDIS_CHANNEL delegate:self];
}

- (void)liveStreamConnected {
  [self.messages insertObject:@"Connected" atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)liveStreamDisconnected {
  [self.messages insertObject:@"Disconnected" atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)liveStreamMessageReceived:(NSDictionary *)message {
  [self.messages insertObject:message atIndex:0];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark -
#pragma Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.messages count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.messages objectAtIndex:indexPath.row]];
  cell.textLabel.numberOfLines = 20;
  cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  cell.textLabel.font = [UIFont systemFontOfSize:12.0];
  
  CGFloat cellHeight = [cell.textLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(self.tableView.frame.size.width, 960) lineBreakMode:UILineBreakModeWordWrap].height;
  CGRect frame = cell.textLabel.frame;
  frame.size.height = cellHeight;
  cell.textLabel.frame = frame;

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
  
  return cell.textLabel.frame.size.height + 20;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  [_messages release];
  [super dealloc];
}

@end
