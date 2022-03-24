//
//  ZSSCustomButtonsViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/14/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSCustomButtonsViewController.h"
#import "ZSSBarButtonItem.h"
#import "ZSSRichTextEditor.h"

@interface ZSSCustomButtonsViewController ()

@property (nonatomic, strong) ZSSRichTextEditor *richTextEditor;

@end

@implementation ZSSCustomButtonsViewController

- (void)loadView {
    _richTextEditor = [[ZSSRichTextEditor alloc] initWithFrame:[UIScreen mainScreen].bounds presentViewController:self];
    self.view = _richTextEditor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"Custom Buttons";
    
    // HTML Content to set in the editor
    NSString *html = @"<p>This editor is using <strong>custom buttons</strong>.</p>";
    
    // Set the HTML contents of the editor
    [self.richTextEditor setHTML:html];
    
    // Don't allow editor toolbar buttons (you can if you want)
    self.richTextEditor.enabledToolbarItems = @[ZSSRichTextEditorToolbarNone];
    
    // Create the custom buttons
    UIButton *myButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50, 28.0f)];
    [myButton setTitle:@"Test" forState:UIControlStateNormal];
    [myButton addTarget:self
                 action:@selector(didTapCustomToolbarButton:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.richTextEditor addCustomToolbarItemWithButton:myButton];
    
    // Custom image button
    ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapCustomToolbarButton:)];
    [self.richTextEditor addCustomToolbarItem:item];
    
}


- (void)didTapCustomToolbarButton:(UIButton *)button {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Custom Button!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
