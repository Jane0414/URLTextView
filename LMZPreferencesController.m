//
//  LMZPreferencesController.m
//  URLTextView
//
//  Created by Cai Honghua on 2017/5/16.
//  Copyright © 2017年 Joni. All rights reserved.
//

#import "LMZPreferencesController.h"

@interface LMZPreferencesController ()
@property (nonatomic,strong) NSTextView *urlText;
@property (nonatomic,strong) NSString *pathFolder;
@end

@implementation LMZPreferencesController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"LMZPreferencesController-----");
        NSRect rct=_urlFolderBtn.frame;
        _urlText=[[NSTextView alloc] initWithFrame:NSMakeRect(51,140, 380, 150)];
        _urlText.backgroundColor=[NSColor clearColor];
        _urlText.editable=NO;
        [self.view addSubview:_urlText];
        //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _pathFolder =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//[paths objectAtIndex:0];
        [_urlText setString:_pathFolder];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)initURLForFile:(id)sender {
    NSString *initPath =_pathFolder;
    NSInteger itemIndex =_urlFolderBtn.indexOfSelectedItem;
    NSString *itemName;
    switch (itemIndex) {
        case 0:
            _pathFolder = initPath;
            itemName=@"桌面";
            break;
        case 1:
            _pathFolder=[self openFolder];
            itemName=[_pathFolder lastPathComponent];
            break;
        default:
            break;
    }
    NSLog(@"urlPath=%@",_pathFolder);
    _urlFolderBtn.selectedItem.title=itemName;
    [_urlText setString:_pathFolder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"initURLForFile"
                                                        object:@"ABC"
                                                      userInfo:[NSDictionary dictionaryWithObject:_pathFolder
                                                                                           forKey:@"name"]];
}
-(NSString *)openFolder{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths lastObject];
    NSLog(@"选择Folder:%@",path);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSURL *url=[NSURL URLWithString:path];
    [panel setDirectoryURL:url];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSOKButton) {
        NSURL *ul=panel.URL;
        path = [ul path];
        [panel close];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 100), dispatch_get_main_queue(), ^(void){
//            [self performSelectorInBackground:@selector(getNewPathTest:) withObject:path];
//        });
    }
    return path;
}

@end
