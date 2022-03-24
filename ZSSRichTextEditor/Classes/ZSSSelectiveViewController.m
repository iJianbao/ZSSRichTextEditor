//
//  ZSSSelectiveViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/14/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSSelectiveViewController.h"
#import "ZSSRichTextEditor.h"

@interface ZSSSelectiveViewController ()

@property (nonatomic, strong) ZSSRichTextEditor *richTextEditor;

@end

@implementation ZSSSelectiveViewController

- (void)loadView {
    _richTextEditor = [[ZSSRichTextEditor alloc] initWithFrame:[UIScreen mainScreen].bounds presentViewController:self];
    self.view = _richTextEditor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Selective";
    
    // HTML Content to set in the editor
    NSString *html = @"<p>Example showing just a few toolbar buttons.</p>";
    
    // Choose which toolbar items to show
    self.richTextEditor.enabledToolbarItems = @[ZSSRichTextEditorToolbarBold, ZSSRichTextEditorToolbarH1, ZSSRichTextEditorToolbarParagraph];
    
    // Set the HTML contents of the editor
    [self.richTextEditor setHTML:html];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
