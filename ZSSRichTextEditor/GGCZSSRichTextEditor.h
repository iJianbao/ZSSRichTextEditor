//
//  GGCZSSRichTextEditor.h
//  LiqForDoctors
//
//  Created by apple on 2020/3/31.
//  Copyright © 2020 iMac. All rights reserved.
//

#import "ZSSRichTextEditor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GGCZSSRichTextEditorUploadImageDelegate <NSObject>

- (NSString *)baseImageUrl;
- (void)uploadImages:(NSArray<UIImage *> *)images complete:(void(^)(NSArray<NSString *> *))completeBlock;

@end

// 间接暴露父类的方法和私有属性
@class ZSSTextView, WKWebView;
@interface GGCZSSRichTextEditor : ZSSRichTextEditor

@property (nonatomic, strong) NSMutableDictionary *baseUrlDict;
// 弹起相机或者图片选择
@property (nonatomic, assign) UIImagePickerControllerSourceType gcImagePickerType;
// 结束编辑
@property (nonatomic, assign) BOOL endEditing;
// 上传图片代理
@property (nonatomic, weak) id<GGCZSSRichTextEditorUploadImageDelegate> uploadImageDelegate;

// 准备插入图片
- (void)insertImageFromDevice;
// 调用相机或者相册
- (void)callCameraPhotoPiacker;

@end

NS_ASSUME_NONNULL_END
