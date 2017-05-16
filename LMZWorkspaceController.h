//
//  LMZWorkspaceController.h
//  URLTextView
//
//  Created by Cai Honghua on 2017/5/9.
//  Copyright © 2017年 Joni. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LMZWorkspaceController : NSViewController
//@property (assign) IBOutlet NSTextField *oldPathText;
@property (assign) IBOutlet NSTextField *oldLabel;
@property (assign) IBOutlet NSTextField *newsLabel;
//@property (assign) IBOutlet NSTableView *tableViewFile;
- (void)initURLForFile:(id)sender;
@end
