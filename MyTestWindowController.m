//
//  MyTestWindowController.m
//  URLTextView
//
//  Created by Cai Honghua on 2017/5/15.
//  Copyright © 2017年 Joni. All rights reserved.
//

#import "MyTestWindowController.h"

@interface MyTestWindowController ()

@end

@implementation MyTestWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSLog(@"MyTestWindowController----");
    [self addController];
}
-(void)addController{
    NSTextField *field=[[NSTextField alloc]initWithFrame:NSMakeRect(20, 20, 100, 30)];
    field.backgroundColor=[NSColor redColor];
}
@end
