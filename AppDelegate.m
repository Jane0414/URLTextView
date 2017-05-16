//
//  AppDelegate.m
//  URLTextView
//https://developer.apple.com/reference/appkit
//  Created by Live365_Joni on 8/18/14.
//  Copyright (c) 2014 Joni. All rights reserved.
//

#import "AppDelegate.h"
#import "URLMatchController.h"
#import "URLReplaceController.h"
#import "LMZWorkspaceController.h"
#import "MyTestWindow.h"
#import "LMZPreferencesController.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
//    self.label.stringValue = @"该Demo展示了使用链接的两种显示方法:\n 1、文本替换  即使用文本代替链接，点击文本可以跳转到相应链接.\n 2、链接检测  即在输入文本的过程中，可以相应检测出链接.";
//
//    URLReplaceController *rCtrl = [[URLReplaceController alloc] initWithNibName:@"URLReplaceController" bundle:nil];
//    [rCtrl.view setFrameOrigin:NSMakePoint(0, self.window.frame.size.height - 2*rCtrl.view.frame.size.height)];
//    [rCtrl replaceURL:[NSURL URLWithString:@"http://www.baidu.com"] forString:@"百度"];
//    [self.window.contentView addSubview:rCtrl.view];
//    
//    URLMatchController *ctrl = [[URLMatchController alloc] initWithNibName:@"URLMatchController" bundle:nil];
//    [self.window.contentView addSubview:ctrl.view];
    LMZWorkspaceController *workspace=[[LMZWorkspaceController alloc]initWithNibName:@"LMZWorkspaceController" bundle:nil];
    [self.window.contentView addSubview:workspace.view];
}
- (IBAction)showPreferences:(id)sender {
    NSLog(@"sdfljsdk");
    [self testWin];
}
-(void)testWin{
    NSRect frame = CGRectMake(0, 20, 450, 350);
    //NSResizableWindowMask 放大 NSMiniaturizableWindowMask 最小化
    NSUInteger style =  NSTitledWindowMask | NSClosableWindowMask|NSBorderlessWindowMask ;
    MyTestWindow *window = [[MyTestWindow alloc]initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES];
    window.title = @"Prefrences";
    //    MyTestWindowController *wincontroller=[[MyTestWindowController alloc] initWithWindow:window];
    LMZPreferencesController *controller=[[LMZPreferencesController alloc]initWithNibName:@"LMZPreferencesController" bundle:nil];
    [window.contentView addSubview:controller.view];
    //窗口显示
    [window makeKeyAndOrderFront:self];
    //窗口居中
    [window center];
}

@end
