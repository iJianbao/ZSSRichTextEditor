//
//  GGCZSSRichTextEditor.m
//  LiqForDoctors
//
//  Created by apple on 2020/3/31.
//  Copyright © 2020 iMac. All rights reserved.
//

#import "GGCZSSRichTextEditor.h"
#import "ZSSTextView.h"
#import "TZImagePickerController.h"

@interface GGCZSSRichTextEditor ()<TZImagePickerControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) TZImagePickerController *tzImagePicker;
@property (nonatomic, copy) NSString *gcOriginHtmlResult;
@end


@implementation GGCZSSRichTextEditor

#pragma mark ------- 重写父类的方法 -------- start
- (void)loadResources {
    //Define correct bundle for loading resources
    NSBundle* bundle = [NSBundle bundleForClass:[ZSSRichTextEditor class]];
    
    //Create a string with the contents of editor.html
    NSString *filePath = [bundle pathForResource:@"GCeditor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [bundle pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [bundle pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [bundle pathForResource:@"GGCZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
    [self setValue:@YES forKey:@"resourcesLoaded"];
}

- (void)setHTML:(NSString *)html {
    // 对部分内容进行处理
    // 1: 双引号去除处理
    NSString *htmlStr = [html stringByReplacingOccurrencesOfString:@"src=\"http" withString:@"src=http"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@".jpg\"" withString:@".jpg"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"style=\"max-width:100%;\"" withString:@""];
    // 2: \n 替换换行符
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [super setHTML:htmlStr];
}

- (void)updateHTML {
//    NSString *html = self.internalHTML;
//    self.sourceView.text = html;
//    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
//    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
//    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
//
//    }];

    NSString *html = self.internalHTML;
    // 源码这里修改顺序，否则css样式丢失
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    self.sourceView.text = cleanedHTML;
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {

    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *query = [navigationAction.request.URL query];
    
    NSString *urlString = [navigationAction.request.URL absoluteString];

    NSLog(@"web request");
    NSLog(@"%@", urlString);
    NSLog(@"%@", query);

    
    if ([urlString rangeOfString:@"myfocuseditor://"].location != NSNotFound) {
        decisionHandler(WKNavigationActionPolicyCancel);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    } else {
        [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

- (void)showInsertImageDialogFromDeviceWithScale:(CGFloat)scale alt:(NSString *)alt {
    if (_gcImagePickerType == UIImagePickerControllerSourceTypeCamera) {
        [self.imagePicker setSourceType:_gcImagePickerType];
        [self.presentViewController presentViewController:self.imagePicker animated:YES completion:nil];
    }else {
        self.selectedImageScale = 0.5;
        self.selectedImageAlt = @"";
        [self.presentViewController presentViewController:self.tzImagePicker animated:YES completion:nil];
    }
}

- (void)insertImageFromDevice {
    // Save the selection location
    [self.editorView evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:^(NSString *result, NSError *error) {
        NSLog(@"准备插入图片 result = %@, error = %@", result, error);
    }];
//    [self showInsertImageDialogFromDeviceWithScale:self.selectedImageScale alt:self.selectedImageAlt];
}

// 调用相机或者相册
- (void)callCameraPhotoPiacker {
    [self showInsertImageDialogFromDeviceWithScale:self.selectedImageScale alt:self.selectedImageAlt];
}

// 此方法插入图片无效
- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImageUrl(\"%@\", \"%@\");", url, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
        NSLog(@"插入图片 result = %@, error = %@", result, error);
    }];
}

- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:^(NSString *result, NSError *error) {
        NSLog(@"插入图片 result = %@, error = %@", result, error);
    }];
}

- (void)getHTML:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    self.gcOriginHtmlResult = nil;
    __weak typeof(self) weakSelf = self;
    [self.editorView evaluateJavaScript:@"zss_editor.getHTML();" completionHandler:^(NSString *_Nullable result, NSError * _Nullable error) {
        // base 转 url
        NSString *resultStr = result;
        for (NSString *keyStr in weakSelf.baseUrlDict.allKeys) {
            if ([resultStr containsString:keyStr]) {
                NSString *replacStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", keyStr];
                resultStr = [resultStr stringByReplacingOccurrencesOfString:replacStr withString:weakSelf.baseUrlDict[keyStr]];
            }
        }
        // 再处理，去掉alt
        weakSelf.gcOriginHtmlResult = resultStr;
        // 对图片进行处理，只保留 img 标签
        [weakSelf scanHtmlImgContent:resultStr withStart:@"<img" withEnd:@">"];
        // 格式化
        NSString *html = [weakSelf removeQuotesFromHTML:weakSelf.gcOriginHtmlResult];
        [weakSelf tidyHTML:html completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            NSLog(@"转换的结果Html = %@", result);
            completionHandler(result, error);
            
        }];
    }];
}

// 去除<img > 标签中的多余属性
- (void)scanHtmlImgContent:(NSString *)htmlStr withStart:(NSString *)startStr withEnd:(NSString *)endStr {
    static NSString *imgOriginInfoStr = @"";
    NSString *scannerStr = htmlStr;
    if ([htmlStr hasPrefix:startStr]) {
        // scanUpToString: 无法扫描开头就符合条件的字符串
        scannerStr = [NSString stringWithFormat:@"GCXGC%@", htmlStr];
    }
    NSLog(@"插入：%@ start %@, end %@", scannerStr, startStr, endStr);
    NSScanner *scanner = [NSScanner scannerWithString:scannerStr];
    // 扫描掉 < 之前的内容（内容）
    NSString *content = nil;
    while ([scanner scanUpToString:startStr intoString:&content] && ![scanner isAtEnd]) {
        scanner.scanLocation += startStr.length;
        // 扫描到 < 到 > 之间的内容（标签）
        NSString *label = nil;
        if ([scanner scanUpToString:endStr intoString:&label]) {
            NSLog(@"img 之间的内容 = %@, %@", label, scanner.locale);
            if (imgOriginInfoStr.length > 0) {
                // 对&quot;进行处理
                label = [label stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
                NSString *replseStr = [NSString stringWithFormat:@"%@%@%@", startStr, label, endStr];
                self.gcOriginHtmlResult = [self.gcOriginHtmlResult stringByReplacingOccurrencesOfString:imgOriginInfoStr withString:replseStr];
                imgOriginInfoStr = @"";
            }else {
                imgOriginInfoStr = label;
                [self scanHtmlImgContent:label withStart:@"src=\"" withEnd:@"\""];
            }
        }else {
            NSLog(@"竟然没有扫描到 >");
        }
    }
}

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}

- (void)tidyHTML:(NSString *)html completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    // 防止出现重复
    html = [html stringByReplacingOccurrencesOfString:@"<br><br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<br /><br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<br><br />" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    
    html = [html stringByReplacingOccurrencesOfString:@"<hr><hr>" withString:@"<hr />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr /><hr>" withString:@"<hr />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr><hr />" withString:@"<hr />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    
    if (self.formatHTML) {
        html = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        [self.editorView evaluateJavaScript:html completionHandler:^(NSString *result, NSError *error) {
            if (error != NULL) {
                NSLog(@"HTML Tidying Error: %@", error);
            }
            NSLog(@"%@", result);
            completionHandler(result, error);
        }];
    } else {
        completionHandler(html, NULL);
    }
}

+ (UIImage *)thumbnailWithImageWithScaleImage:(UIImage *)image percent:(float)percent {
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGSize asize = CGSizeMake(image.size.width * percent, image.size.height * percent);
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
#pragma mark ------- 重写父类的方法 -------- end

#pragma mark - 代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
    CGSize targetSize = CGSizeMake(selectedImage.size.width * self.selectedImageScale, selectedImage.size.height * self.selectedImageScale);
    UIGraphicsBeginImageContext(targetSize);
    [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, 0.8);
    NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
    selectedImage = [GGCZSSRichTextEditor thumbnailWithImageWithScaleImage:selectedImage percent:.5];
    __weak typeof(self) weakSelf = self;
    [self.uploadImageDelegate uploadImages:[selectedImage] complete:^(NSArray<NSString *> * urlAry) {
        for (int i = 0; i < urlAry.count; i++) {
            NSString *imageURL = [NSString stringWithFormat:@"%@/%@",kBaseImageURL, urlAry[i]];
            [weakSelf.baseUrlDict addObject:imageURL forKey:base64Ary[i]];
            [weakSelf insertImageBase64String:base64Ary[i] alt:weakSelf.selectedImageAlt];
            weakSelf.imageBase64String = base64Ary[i];
        }
        //Dismiss the Image Picker
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
//    [CommonTool submitImageToServeWithImage:[CommonTool thumbnailWithImageWithScaleImage:selectedImage percent:.5] successBlock:^(id responseObjc) {
//        @strongify(self);
//        if ([responseObjc[@"status"] integerValue] == 1) {
//            // 上传成功，最后上传到服务器，将base64 替换成url
//            NSString * imageURL = [NSString stringWithFormat:@"%@/%@", kBaseImageURL, responseObjc[@"url"]];
//            [self.baseUrlDict addObject:imageURL forKey:imageBase64String];
//            [self insertImageBase64String:imageBase64String alt:self.selectedImageAlt];
//            self.imageBase64String = imageBase64String;
//        }
//        //Dismiss the Image Picker
//        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//    } isWartermask:NO];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker
       didFinishPickingPhotos:(NSArray<UIImage *> *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
                        infos:(NSArray<NSDictionary *> *)infos {
    NSMutableArray<NSString *> *base64Ary = @[].mutableCopy;
    NSMutableArray<UIImage *> *imageAry = @[].mutableCopy;
    for (UIImage *selectedImage in photos) {
        CGSize targetSize = CGSizeMake(selectedImage.size.width * self.selectedImageScale, selectedImage.size.height * self.selectedImageScale);
        UIGraphicsBeginImageContext(targetSize);
        [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, 0.8);
        NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
        
        [imageAry addObject:scaledImage];
        [base64Ary addObject:imageBase64String];
    }
    __weak typeof(self) weakSelf = self;
    [self.uploadImageDelegate uploadImages:imageAry complete:^(NSArray<NSString *> * urlAry) {
        for (int i = 0; i < urlAry.count; i++) {
            NSString *imageURL = [NSString stringWithFormat:@"%@/%@",kBaseImageURL, urlAry[i]];
            [weakSelf.baseUrlDict addObject:imageURL forKey:base64Ary[i]];
            [weakSelf insertImageBase64String:base64Ary[i] alt:weakSelf.selectedImageAlt];
            weakSelf.imageBase64String = base64Ary[i];
        }
    }];
//    [CommonTool submitImageToServeWithImages:imageAry successBlock:^(id responseObjc) {
//        @strongify(self);
//        if ([responseObjc[@"status"] integerValue] == 1) {
//            NSArray *urlAry = [[NSString stringWithFormat:@"%@", responseObjc[@"url"]] componentsSeparatedByString:@","];
//            for (int i = 0; i < urlAry.count; i++) {
//                NSString * imageURL = [NSString stringWithFormat:@"%@/%@",kBaseImageURL, urlAry[i]];
//                [self.baseUrlDict addObject:imageURL forKey:base64Ary[i]];
//                [self insertImageBase64String:base64Ary[i] alt:self.selectedImageAlt];
//                self.imageBase64String = base64Ary[i];
//            }
//        }
//    } isWartermask:NO];
}

- (TZImagePickerController *)tzImagePicker {
    if (_tzImagePicker == nil) {
        _tzImagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        _tzImagePicker.allowPickingVideo = NO;
    }
    return _tzImagePicker;
}

- (NSMutableDictionary *)baseUrlDict {
    if (_baseUrlDict == nil) {
        _baseUrlDict = @{}.mutableCopy;
    }
    return _baseUrlDict;
}

- (void)setEndEditing:(BOOL)endEditing {
    // Call the setEndEditing
    NSString *js = [NSString stringWithFormat:@"zss_editor.setEndEditing();"];
    [self.editorView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
     
    }];
}

- (void)dealloc {
    NSLog(@"___%s___", __FUNCTION__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
