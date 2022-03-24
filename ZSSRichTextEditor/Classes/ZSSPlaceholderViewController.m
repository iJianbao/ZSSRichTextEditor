//
//  ZSSPlaceholderViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/14/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSPlaceholderViewController.h"
#import "ZSSRichTextEditor.h"

@interface ZSSPlaceholderViewController ()

@property (nonatomic, strong) ZSSRichTextEditor *richTextEditor;

@end

@implementation ZSSPlaceholderViewController

- (void)loadView {
    _richTextEditor = [[ZSSRichTextEditor alloc] initWithFrame:[UIScreen mainScreen].bounds presentViewController:self];
    self.view = _richTextEditor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Placeholder";
    
    self.richTextEditor.placeholder = @"Please tap to start editing";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
