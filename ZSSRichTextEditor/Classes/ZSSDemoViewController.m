//
//  ZSSDemoViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/29/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoViewController.h"
#import "ZSSDemoPickerViewController.h"
#import "ZSSRichTextEditor.h"

#import "DemoModalViewController.h"


@interface ZSSDemoViewController ()

@property (nonatomic, strong) ZSSRichTextEditor *richTextEditor;

@end

@implementation ZSSDemoViewController

- (void)loadView {
    _richTextEditor = [[ZSSRichTextEditor alloc] initWithFrame:[UIScreen mainScreen].bounds presentViewController:self];
    self.view = _richTextEditor;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Standard";
    
    //Set Custom CSS
    NSString *customCSS = @"";
    [_richTextEditor setCSS:customCSS];
        
    _richTextEditor.alwaysShowToolbar = YES;
    _richTextEditor.receiveEditorDidChangeEvents = NO;
    
    // Export HTML
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
    
    // HTML Content to set in the editor
    NSString *html = @"<div class='test'></div><!-- This is an HTML comment -->"
    "<p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
    
    // Set the base URL if you would like to use relative links, such as to images.
    _richTextEditor.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
    _richTextEditor.shouldShowKeyboard = NO;
    // Set the HTML contents of the editor
    [_richTextEditor setPlaceholder:@"This is a placeholder that will show when there is no content(html)"];
    
    [_richTextEditor setHTML:html];
    
}


- (void)showInsertURLAlternatePicker {
    
    [_richTextEditor dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)showInsertImageAlternatePicker {
    
    [_richTextEditor dismissAlertView];
    
    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
    picker.demoView = self;
    picker.isInsertImagePicker = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)exportHTML {
    [self.richTextEditor getHTML:^(NSString *result, NSError * _Nullable error) {
        NSLog(@"%@", result);
    }];
}

- (void)editorDidChangeWithText:(NSString *)text andHTML:(NSString *)html {
    
    NSLog(@"Text Has Changed: %@", text);
    
    NSLog(@"HTML Has Changed: %@", html);
    
}

- (void)hashtagRecognizedWithWord:(NSString *)word {
    
    NSLog(@"Hashtag has been recognized: %@", word);
    
}

- (void)mentionRecognizedWithWord:(NSString *)word {
    
    NSLog(@"Mention has been recognized: %@", word);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
