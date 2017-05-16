//
//  LMZPreferencesController.h
//  URLTextView
//
//  Created by Cai Honghua on 2017/5/16.
//  Copyright © 2017年 Joni. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LMZPreferencesController : NSViewController
@property (assign) IBOutlet NSPopUpButton *urlFolderBtn;

- (IBAction)initURLForFile:(id)sender;
@end
