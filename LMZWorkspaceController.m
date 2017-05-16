//
//  LMZWorkspaceController.m
//  URLTextView
//
//  Created by Cai Honghua on 2017/5/9.
//  Copyright © 2017年 Joni. All rights reserved.
//

#import "LMZWorkspaceController.h"
#import "MyTestView.h"
#import "MyTestWindowController.h"
#import "LMZPreferencesController.h"
#import "MyTestWindow.h"
#import "AppDelegate.h"

@interface LMZWorkspaceController ()<NSTableViewDelegate,NSTableViewDataSource>
{
    
    NSScrollView *_tableContainerView;
//    NSMutableArray *_dataSourceArray;
    NSTextField *_scrollTF;
    NSButton *_deleteBtn;
    NSButton *_addBtn;
    NSMutableArray *tableArray;
    
    NSInteger _selectedRowNum;
}
@property (nonatomic,strong)  NSMutableArray *identicalArray;//相同文件名和相同文件大小
@property (nonatomic,strong) NSMutableArray *changedArray;//相同文件名 内容不同
@property (nonatomic,strong) NSMutableArray *newsArray;//新增的文件
@property (nonatomic,strong) NSMutableArray *itReNameArray;//不同名字 相同内容
@property (nonatomic,strong) NSMutableArray *obsoleteArray;//A文件夹中已删除的文件
@property (nonatomic,strong) NSOpenPanel *panel; //选择文件
@property (nonatomic,strong) NSString *oldPath;//old文件路径
@property (nonatomic,strong) NSString *newsPath;//new文件路径
@property (nonatomic,strong) NSString *initURL;//初始文件路径
@property (nonatomic,strong) NSMutableString *contents; // 打印内容
@property (nonatomic,strong) NSString *printPath;//打印文件存储路径
@property (nonatomic,strong) NSString *fileNewsName;//打印文件名
@property (nonatomic,strong) NSString *fileOldName;//打印文件名
@property (nonatomic) NSTableView *tableView;
@property (nonatomic,strong)  NSMutableArray *allDiffTypes;//所有不同type

@end

@implementation LMZWorkspaceController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.tableViewFile=[[NSTableView alloc]init];
//        _tableViewFile.delegate=self;
//        _tableViewFile.dataSource=self;
        self.allDiffTypes=[NSMutableArray array];
        _initURL=NSHomeDirectory();
        _scrollTF=[[NSTextField alloc] init];
        _scrollTF.hidden=YES;
        _scrollTF.stringValue=NSHomeDirectory();
        [self addOtherTableView];
    }
    return self;
}
-(void)addOtherTableView{
    _selectedRowNum = -1;
    //tableView
    _tableContainerView = [[NSScrollView alloc] initWithFrame:CGRectMake(60, 0,self.view.bounds.size.width, 300)];
    _tableView = [[NSTableView alloc] initWithFrame:CGRectMake(5, 5,
                                                               _tableContainerView.frame.size.width-10,
                                                               _tableContainerView.frame.size.height-5)];
//    [_tableView setBackgroundColor:[NSColor colorWithCalibratedRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]];
    _tableView.focusRingType = NSFocusRingTypeNone;                             //tableview获得焦点时的风格
    _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;//行高亮的风格
    _tableView.headerView.frame=NSMakeRect(5, 0, _tableView.frame.size.width, 25);//表头
    //设置tableview横条 竖条
//    [_tableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //Diff Type
    [self addTableColumn:@"Diff Type" withTitle:@"Diff Type"];
    //All
    [self addTableColumn:@"All" withTitle:@"All"];
    //psd
    [self addTableColumn:@"psd" withTitle:@".psd"];
    //ai
    [self addTableColumn:@"ai" withTitle:@".ai"];
    //png
    [self addTableColumn:@"png" withTitle:@".png"];
    
    [_tableContainerView setDocumentView:_tableView];
    [_tableContainerView setDrawsBackground:YES];        //画背景（背景默认画成白色）
    _tableContainerView.backgroundColor=[NSColor clearColor];
    [_tableContainerView setHasVerticalScroller:YES];   //有垂直滚动条
    //[_tableContainer setHasHorizontalScroller:YES];   //有水平滚动条
    _tableContainerView.autohidesScrollers = YES;       //自动隐藏滚动条（滚动的时候出现）
    [self.view addSubview:_tableContainerView];
    
    //监测tableview滚动
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(tableviewDidScroll:)
//                                                name:NSViewBoundsDidChangeNotification
//                                              object:[[_tableView enclosingScrollView] contentView]];
}
-(void)addTableColumn:(NSString *)identifier withTitle:(NSString *)title{
    NSTableColumn * column2 = [[NSTableColumn alloc] initWithIdentifier:identifier];
//    // 3.1.设置最小的宽度
    column2.minWidth= 80.0;
//    // 3.2.允许用户调整宽度
    column2.resizingMask = NSTableColumnUserResizingMask;
    if ([identifier isEqualToString:@"Diff Type"]) {
        [column2 setWidth:150];
    }else{
        [column2 setWidth:100];
    }
    [column2 setTitle:title];
    [_tableView addTableColumn:column2];
}

//这个方法虽然不返回什么东西，但是必须实现，不实现可能会出问题－比如行视图显示不出来等。（10.11貌似不实现也可以，可是10.10及以下还是不行的）
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}
#pragma mark -other methods
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 35;
}
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier=[tableColumn identifier];
    NSTableCellView *aView = [tableView makeViewWithIdentifier:identifier owner:self];
    if (!aView)
        aView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, tableColumn.width, 35)];
    else
        for (NSView *view in aView.subviews)[view removeFromSuperview];
   /* NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
    textView.string=
    textField.stringValue = textVal;//textField.backgroundColor=[NSColor redColor];
    textField.font = [NSFont systemFontOfSize:15.0f];
    textField.textColor = [NSColor blackColor];*/
    NSDictionary *cellDict=[_allDiffTypes objectAtIndex:row];
    NSString *textVal=[cellDict objectForKey:identifier];
    NSTextView *textView=[[NSTextView alloc]initWithFrame:CGRectMake(10, 10, 120, 20)];
    textView.string=textVal;
//    textField.backgroundColor=[NSColor redColor];
    if ([textVal isEqualToString:@"New"]) {
        textView.backgroundColor=[NSColor redColor];
    }else if ([textVal isEqualToString:@"Changed"]) {
        textView.backgroundColor=[NSColor yellowColor];
    }else if ([textVal isEqualToString:@"Identical"]) {
        textView.backgroundColor=[NSColor greenColor];
    }else if ([textVal isEqualToString:@"Identical ReName"]) {
        textView.backgroundColor=[NSColor greenColor];
    }else if ([textVal isEqualToString:@"Obsolete"]) {
        textView.backgroundColor=[NSColor lightGrayColor];
    }else{
        textView.backgroundColor=[NSColor clearColor];
    }
    //是否显示背景颜色
    textView.drawsBackground = YES;
//    textField.bordered = NO;
    textView.focusRingType = NSFocusRingTypeNone;
    textView.editable = YES;
    [aView addSubview:textView];
    return aView;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    _selectedRowNum = row;
    return YES;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return _allDiffTypes.count;
}

- (IBAction)selectNewFolder:(id)sender {
    @autoreleasepool{
         [self getPathWithNewsFolder];
    }
    
}
- (IBAction)selectOldFolder:(id)sender {
    @autoreleasepool{
        [self getPathWithOldFolder];
    }
    
}

- (IBAction)compareFile:(id)sender {
    if (!_oldPath) {
        [self showalert:@"请选择Old Folder"];
        return;
    }else if(!_newsPath){
        [self showalert:@"请选择New Folder"];
        return;
    }
    NSLog(@"oldText=%@\nnewText=%@",self.oldLabel.stringValue,self.newsLabel.stringValue);
    NSLog(@"oldPath=%@\nnewPath=%@",_oldPath,_newsPath);
    NSLog(@"oldPath=%@\nnewPath=%@",_oldPath,_newsPath);
    [self.allDiffTypes removeAllObjects];
    
    //所有文件目录列表
    NSDictionary *dictA=[self saveFoldsWithDictionary:self.oldLabel.stringValue];
    NSDictionary *dictB=[self saveFoldsWithDictionary:self.newsLabel.stringValue];
    NSLog(@"Acount=%ld,Bcount=%ld",dictA.count,dictB.count);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self compareWithDict:dictA withDict:dictB];
//        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"刷新数据：%@",_allDiffTypes[0]);
            NSLog(@"_allDiffTypes===刷新数据：%ld",_allDiffTypes.count);
            [_tableView reloadData];
        });
    });
}

-(void)compareWithDict:(NSDictionary *)dictA withDict:(NSDictionary *)dictB{
    NSMutableDictionary *identicalDict=[NSMutableDictionary dictionary];//相同文件名和相同文件大小
    NSMutableDictionary *changedDict=[NSMutableDictionary dictionary];//相同文件名 内容不同
    NSMutableDictionary *newsDict=[NSMutableDictionary dictionary];//新增的文件
    NSMutableDictionary *obsoleteDict=[NSMutableDictionary dictionary];//A文件夹中已删除的文件
    _itReNameArray=[NSMutableArray array];//不同名字 相同内容
    NSMutableDictionary *deleteDict=[NSMutableDictionary dictionaryWithDictionary:dictA];
    //所有Diff Type
    NSMutableString *pathB,*pathA;
    for (NSString *keyB in dictB) {
        int diff=0;
        pathB=[dictB objectForKey:keyB];
//        NSLog(@"属性%@",[keyB pathExtension]);
        for (NSString *keyA in dictA) {
            pathA=[dictA objectForKey:keyA];
            if ([keyB isEqualTo:keyA]) {//文件名相同 内容相同
                [deleteDict removeObjectForKey:keyA];//从删除数组中移除
                if([self compareWtihContent:pathB withPath:pathA]){
                    [identicalDict setObject:pathB forKey:keyB];
//                    [_identicalArray addObject:pathB];
                }else{//文件名相同 内容不同 changed
                    [changedDict setObject:pathB forKey:keyB];
//                    [_changedArray addObject:pathB];
                }
            }else if(![keyB isEqualTo:keyA]){//文件名不同 内容相同
                if ([self compareWtihContent:pathB withPath:pathA]) {
                    NSMutableDictionary *itReName=[NSMutableDictionary dictionary];
                    //内容相同 文件名不同
                    [itReName setObject:pathA forKey:keyA];
                    [itReName setObject:pathB forKey:keyB];
                    [_itReNameArray addObject:itReName];
                }else{
                    diff++;
                }
            }
        }
        if (dictA.count==diff) {
            //新增的文件
//            [_newsArray addObject:pathB];
            [newsDict setObject:pathB forKey:keyB];
        }
    }
    
    for (NSString *keyB in deleteDict) {//循环数组B
        pathB=[deleteDict objectForKey:keyB];//获取数组B的值
        //已经删除的文件
//        [_obsoleteArray addObject:pathB];
        [obsoleteDict setObject:pathB forKey:keyB];
    }
    
    _printPath=[_newsPath stringByDeletingLastPathComponent];
    _fileNewsName=[_newsPath lastPathComponent];
    _fileOldName=[_oldPath lastPathComponent];
    NSLog(@"printPath = %@,fileNewsname=%@,fileOldname=%@",_printPath,_fileNewsName,_fileOldName);
    NSLog(@"新增文件=%ld,更新=%ld,文件名相同内容相同=%ld,文件名不同内容相同=%ld,已删除文件=%ld",newsDict.count,changedDict.count,identicalDict.count,_itReNameArray.count,obsoleteDict.count);
//    NSString *homepath=@"/Users/caihonghua/Documents/B";
    //获取Old对比文件夹的名称命名
//    NSLog(@"_fileOldName=%@",_fileOldName);
    NSString *iOSPath = [_newsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@<Diff>%@.txt",_fileOldName,_fileNewsName]];
    _contents=nil;
    _contents=[NSMutableString stringWithFormat:@"Old:%@\nNew:%@",_fileOldName,_fileNewsName];
   
    NSData *data=[_contents dataUsingEncoding:NSUTF8StringEncoding];
    NSFileManager *fileManager=[[NSFileManager alloc]init];
    BOOL isSuccess=[fileManager createFileAtPath:iOSPath contents:data attributes:nil];
    
    if (isSuccess) {
        NSString *attru=nil;//属性
        int psd=0;int ai=0;int png=0;
//        [_tableView beginUpdates];
        NSLog(@"write success");
        _contents=[NSMutableString stringWithFormat:@"\n\n\nNew：%ld\nChanged：%ld\nIdentical：%ld\nIdentical ReName：%ld\nObsolete：%ld\n%@",newsDict.count,changedDict.count,identicalDict.count,_itReNameArray.count,obsoleteDict.count,@"============================================================"];
        //New
        [_contents appendFormat:@"\n\n\nNew：%ld\n\n",newsDict.count];
    
        for (NSString *key in newsDict) {
            attru=[key pathExtension];
            if ([attru isEqualToString:@"png"]) {
                png++;
            }else if([attru isEqualToString:@"psd"]){
                psd++;
            }else if([attru isEqualToString:@"ai"]){
                ai++;
            }
            [_contents appendFormat:@"\n%@              path=%@",key,[newsDict objectForKey:key]];
        }
        [_allDiffTypes addObject:[self returnDiffType:@"New" withCount:newsDict.count withPsd:psd withAi:ai withPng:png]];
        psd=0;ai=0;png=0;
        //_newsDetail.atitle.length > 0 ? 2 : 1;
        //Changed
        [_contents appendFormat:@"\n\n\nChange：%ld\n\n",changedDict.count];
        for (NSString *key in changedDict) {
            attru=[key pathExtension];
            if ([attru isEqualToString:@"png"]) {
                png++;
            }else if([attru isEqualToString:@"psd"]){
                psd++;
            }else if([attru isEqualToString:@"ai"]){
                ai++;
            }
            [_contents appendFormat:@"\n%@              path=%@",key,[changedDict objectForKey:key]];
        }
        [_allDiffTypes addObject:[self returnDiffType:@"Changed" withCount:changedDict.count withPsd:psd withAi:ai withPng:png]];
        psd=0;ai=0;png=0;
        //Identical
        [_contents appendFormat:@"\n\n\nIdentical：%ld\n\n",identicalDict.count];
        for (NSString *key in identicalDict) {
            attru=[key pathExtension];
            if ([attru isEqualToString:@"png"]) {
                png++;
            }else if([attru isEqualToString:@"psd"]){
                psd++;
            }else if([attru isEqualToString:@"ai"]){
                ai++;
            }
            [_contents appendFormat:@"\n%@              path=%@",key,[identicalDict objectForKey:key]];
        }
        [_allDiffTypes addObject:[self returnDiffType:@"Identical" withCount:identicalDict.count withPsd:psd withAi:ai withPng:png]];
        psd=0;ai=0;png=0;
        
        //Identical ReName
        [_contents appendFormat:@"\n\n\nIdentical ReName：%ld\n\n",_itReNameArray.count];
        for (int i=0; i<_itReNameArray.count;i++) {
            NSDictionary *dict=_itReNameArray[i];
            NSMutableArray *array=[NSMutableArray array];
            for (NSString *key in dict) {
                [array addObject:key];
            }
            for (int j=0; j<array.count; j++) {
                if (j>0) {
                    attru=[array[j] pathExtension];
                    if ([attru isEqualToString:@"png"]) {
                        png++;
                    }else if([attru isEqualToString:@"psd"]){
                        psd++;
                    }else if([attru isEqualToString:@"ai"]){
                        ai++;
                    }
                    [_contents appendFormat:@" ==> %@",array[j]];
                }else{
                    [_contents appendFormat:@"\n%@",array[j]];
                }
            }
        }
        [_allDiffTypes addObject:[self returnDiffType:@"Identical ReName" withCount:_itReNameArray.count withPsd:psd withAi:ai withPng:png]];
        psd=0;ai=0;png=0;
        
        //Obsolete
        [_contents appendFormat:@"\n\n\nObsolete：%ld\n\n",obsoleteDict.count];
        for (NSString *key in obsoleteDict) {
            [_contents appendFormat:@"\n%@  path=%@",key,[obsoleteDict objectForKey:key]];
            attru=[key pathExtension];
            if ([attru isEqualToString:@"png"]) {
                png++;
            }else if([attru isEqualToString:@"psd"]){
                psd++;
            }else if([attru isEqualToString:@"ai"]){
                ai++;
            }
        }
        [_allDiffTypes addObject:[self returnDiffType:@"Obsolete" withCount:obsoleteDict.count withPsd:psd withAi:ai withPng:png]];
        psd=0;ai=0;png=0;
//        [_tableView endUpdates];
        
            NSFileHandle *writeHandel=[NSFileHandle fileHandleForUpdatingAtPath:iOSPath];
            [writeHandel seekToEndOfFile];//将节点跳到文件的末尾
            data=[_contents dataUsingEncoding:NSUTF8StringEncoding];
            [writeHandel writeData:data];
            [writeHandel closeFile];
//        });
    } else {
        NSLog(@"write fail");
    }
    NSLog(@"临时---刷新数据：%@",_allDiffTypes);
//    _allDiffTypes=[_allDiffTypes initWithArray:linDict copyItems:YES];
//    _allDiffTypes=[NSMutableArray arrayWithArray:linDict];
    NSLog(@"_allDiffTypes---刷新数据：%ld",_allDiffTypes.count);
}
-(NSMutableDictionary *)returnDiffType:(NSString *)str withCount:(NSInteger)count withPsd:(int)psd withAi:(int)ai withPng:(int)png{
    NSMutableDictionary *dictChanged=[NSMutableDictionary dictionary];//临时存放
    [dictChanged setObject:str forKey:@"Diff Type"];
    [dictChanged setObject:[NSString stringWithFormat:@"%ld",count] forKey:@"All"];
    [dictChanged setObject:[NSString stringWithFormat:@"%d",psd] forKey:@"psd"];
    [dictChanged setObject:[NSString stringWithFormat:@"%d",ai] forKey:@"ai"];
    [dictChanged setObject:[NSString stringWithFormat:@"%d",png] forKey:@"png"];
    NSLog(@"dictchanged=%@",dictChanged);
    return dictChanged;
}
//NSFileHandle写入文件
-(void)writeWithFileHandle{
    
}
//比较两个文件内容 简历版
-(BOOL)compareWtihContent:(NSString *)path1 withPath:(NSString *)path2{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL isDir;
    BOOL contentsFlag=NO;
    if ([fileManager fileExistsAtPath:path1 isDirectory:(&isDir)]&&[fileManager fileExistsAtPath:path1 isDirectory:(&isDir)]) {
        if (!isDir){
            contentsFlag=[fileManager contentsEqualAtPath:path1 andPath:path2];
        }
    }
    return contentsFlag;
}
//循环存储所有的子文件夹
-(NSDictionary *)saveFoldsWithDictionary:(NSString *)homepath{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSDirectoryEnumerator *directory=[fileManager enumeratorAtPath:homepath];
   directory=[fileManager enumeratorAtPath:homepath];
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",homepath);
    BOOL isDir;
    NSString *fileName,*path;
    while((path=[directory nextObject])!=nil)
    {
        path=[homepath stringByAppendingPathComponent:path];
        if ([fileManager fileExistsAtPath:path isDirectory:(&isDir)]) {
            if (!isDir){//不是文件夹
                fileName=[path lastPathComponent];
//                NSLog(@"fileName=%@,path=%@",[path lastPathComponent],path);
                [dict setObject:path forKey:fileName];
            }
        }
    }
    return dict;
}

-(void)getPathWithNewsFolder{
//    NSString *path=NSHomeDirectory();
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =_initURL; //[paths objectAtIndex:0];
    NSLog(@"getPathWithOldFolder--------path=%@",_scrollTF.stringValue);
    _panel=nil;
    _panel = [NSOpenPanel openPanel];
    NSURL *url=[NSURL URLWithString:_scrollTF.stringValue];
    [_panel setDirectoryURL:url];
    [_panel setAllowsMultipleSelection:NO];
    [_panel setCanChooseDirectories:YES];
    [_panel setCanChooseFiles:YES];
    [_panel setAllowsOtherFileTypes:YES];
    if ([_panel runModal] == NSOKButton) {
        NSURL *ul=_panel.URL;
        path = [ul path];
        [_panel close];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 100), dispatch_get_main_queue(), ^(void){
            [self performSelectorInBackground:@selector(getNewPathTest:) withObject:path];
        });
    }
}
-(void)getNewPathTest:(NSString *)p{
    self.newsLabel.stringValue=p;
//    NSString *oldVal=self.oldLabel.stringValue;
//    if (oldVal) {//如果已经选择了Old文件夹
//        [self.oldPathText setStringValue:[oldVal stringByAppendingFormat:@"\nNew：%@",p]];//[NSString stringWithFormat:@"Old：%@\nNew：%@",oldVal,_newsPath];
//    }else{//没有选择Old文件夹
//        [self.oldPathText setStringValue:[NSString stringWithFormat:@"New：%@",p]];
//    }
//    NSLog(@"selectNewFolder-----newPath=%@,oldVal=%@,oldPath=%@",p,oldVal,oldVal);
    _newsPath=p;
}
-(void)getPathWithOldFolder{
    //@"/Users/caihonghua/Documents/SS";
//        NSString *testPath=_initURL;
    NSLog(@"getPathWithOldFolder--------path=%@",_scrollTF.stringValue);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path=_scrollTF.stringValue;
    _panel=nil;
    _panel = [NSOpenPanel openPanel];
    NSURL *url=[NSURL URLWithString:path];
    [_panel setDirectoryURL:url];
//        [panel setDirectory:path];
    [_panel setAllowsMultipleSelection:NO];
    [_panel setCanChooseDirectories:YES];
    [_panel setCanChooseFiles:YES];
    //    [panel setAllowedFileTypes:@[@"onecodego"]];//
    [_panel setAllowsOtherFileTypes:YES];
    if ([_panel runModal] == NSOKButton) {
//        path = [panel.URLs.firstObject path];
        NSURL *ul=_panel.URL;
        path = [ul path];
        [_panel close];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 100), dispatch_get_main_queue(), ^(void){
            [self performSelectorInBackground:@selector(getOldPathTest:) withObject:path];
        });
        
//        [_panel setIsVisible:false];
    }
    });
}
-(void)getOldPathTest:(NSString *)p{
    self.oldLabel.stringValue=p;
//    NSString *newVal=self.newsLabel.stringValue;
//    if (newVal) {//如果已经选择了New Folder
//        //        _newsPath=newVal;
//        [self.oldPathText setStringValue:[NSString stringWithFormat:@"Old：%@\nNew：%@",p,newVal]];
//    }else{
//        [self.oldPathText setStringValue:[NSString stringWithFormat:@"Old：%@",p]];
//    }
//    NSLog(@"selectOldFolder-----news=%@,newVal=%@,oldPath=%@",_newsPath,newVal,p);
    _oldPath=p;
}

-(void)showalert:(NSString *)title{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"提示";
    [alert setShowsHelp:NO];
    alert.informativeText = title;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

- (IBAction)alertWindow:(id)sender {//NSLog(@"alertWindow----11");
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
-(void)testWin1{
    AppDelegate *app = [[NSApplication sharedApplication] delegate];
//    NSWindow *mainWindow = app.window;
    CGFloat width = 450;
    CGFloat height = 400;
    NSRect popupWindowRect =NSMakeRect(50, 50, width, height);// NSMakeRect(NSMidX(mainWindow.frame)-width/2,NSMidY(mainWindow.frame)-height/2, width, height);
    //    MyTestWindowController *popupWindow = [[MyTestWindowController alloc] initWithContentRect:popupWindowRect styleMask:NSClosableWindowMask | NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    //    MyTestWindowController *wincontroller = [[MyTestWindowController alloc] initWithWindow:popupWindow];
    //    [wincontroller showWindow:nil];
    NSLog(@"alertWindow----");
    MyTestWindow *win=[[MyTestWindow alloc] initWithContentRect:popupWindowRect
                                                      styleMask:NSClosableWindowMask | NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    win.styleMask=NSClosableWindowMask;
    MyTestWindowController *wincontroller = [[MyTestWindowController alloc] initWithWindow:win];
    [wincontroller showWindow:nil];
    [[NSApplication sharedApplication] runModalForWindow:win];
    NSRect coverViewRect = NSMakeRect(5, 5, width, height);
    MyTestView *popupView=[[MyTestView alloc] initWithFrame:coverViewRect];
    [win.contentView addSubview:popupView];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initURLForFile:)
                                                 name:@"initURLForFile"
                                               object:nil];
}
- (void)initURLForFile:(id)sender{
    _scrollTF.stringValue=[[sender userInfo] objectForKey:@"name"];
    NSLog(@"WorkspaceController---initURL===----%@",_scrollTF.stringValue);
}

@end
