//
//  do_Bitmap_MM.m
//  DoExt_MM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Bitmap_MM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "doJsonHelper.h"
#import "doIOhelper.h"
#import "doUIModuleHelper.h"
#import "doIPage.h"
#import "doUIModule.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "doTextHelper.h"

#define FONT_OBLIQUITY 15.0


@interface do_Bitmap_MM()
@property (nonatomic,strong) UIImage *img;
@end

@implementation do_Bitmap_MM

#pragma mark - 注册属性（--属性定义--）
/*
 [self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];
    //注册属性
}

//销毁所有的全局对象
-(void)Dispose
{
    //(self)类销毁时会调用递归调用该方法，在该类中主动生成的非原生的扩展对象需要主动调该方法使其销毁
    self.img = nil;
}
#pragma mark -
#pragma mark - 同步异步方法的实现
//同步
//异步
- (void)loadFile:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //_invokeResult设置返回值
    __weak do_Bitmap_MM *weakSelf = self;
    NSString *imgSource = [doJsonHelper GetOneText:_dictParas :@"source" :@""];
    if ([imgSource hasPrefix:@"http"]) {//网络图片
        NSURLSession *session = [NSURLSession sharedSession];
        imgSource = [imgSource stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:imgSource];
        NSURLSessionDownloadTask *downTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            weakSelf.img = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            if (weakSelf.img) {
                [_invokeResult SetResultBoolean:YES];
            }
            else
            {
                [_invokeResult SetResultBoolean:NO];
            }
            [_scritEngine Callback:_callbackName :_invokeResult];
        }];
        [downTask resume];
    }//本地图片
    else if([imgSource hasPrefix:@"data://"]||[imgSource hasPrefix:@"source://"] || [imgSource hasPrefix:@"initdata://"])
    {
        NSString *imgPath = [doIOHelper GetLocalFileFullPath:self.CurrentApp :imgSource];
        self.img = [UIImage imageWithContentsOfFile:imgPath];
        if (self.img) {
            [_invokeResult SetResultBoolean:YES];
        }
        else
        {
            [_invokeResult SetResultBoolean:NO];
        }
        [_scritEngine Callback:_callbackName :_invokeResult];
    }
}
- (void)save:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    
    //自己的代码实现
    if (self.img) {
        NSString *_callbackName = [parms objectAtIndex:2];
        //回调函数名_callbackName
        doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
        //_invokeResult设置返回值
        NSString *format = @"JPEG";
        format = [doJsonHelper GetOneText:_dictParas :@"format" :@"JPEG"];
        if ([format compare:@"PNG" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            format = @"PNG";
        }
        else
        {
            format = @"JPEG";
        }
        //默认文件名字
        NSString *fileName = [NSString stringWithFormat:@"%@.%@",[doUIModuleHelper stringWithUUID],format];
        NSString *defaultFilePath = [NSString stringWithFormat:@"%@/%@",@"data://temp/do_Bitmap",fileName];
        int quality = [doJsonHelper GetOneInteger:_dictParas :@"quality" :100] / 100;
        NSString *outPath = [doJsonHelper GetOneText :_dictParas :@"outPath" :defaultFilePath];
        NSString *tempPath = [outPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(tempPath.length == 0)
        {
            outPath = defaultFilePath;
        }
        NSData *jpgData;
        if ([format isEqualToString:@"PNG"])
        {
            jpgData = UIImagePNGRepresentation(self.img);
        }
        else
        {
            jpgData = UIImageJPEGRepresentation(self.img, quality);
        }
        NSString *filePath =  [doIOHelper GetLocalFileFullPath:self.CurrentApp :outPath];
        NSString *dicPath = [filePath stringByDeletingLastPathComponent];
        //文件夹不存在，创建
        if (![doIOHelper ExistDirectory:dicPath]) {
            [doIOHelper CreateDirectory:dicPath];
        }
        
        NSLog(@"saveFilePath = %@",filePath);
        [jpgData writeToFile:filePath atomically:YES];
        //返回值
        [_invokeResult SetResultText:outPath];
        [_scritEngine Callback:_callbackName :_invokeResult];
    }
}
- (void)toFrostedGlass:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];

    //自己的代码实现
    int degree = [doJsonHelper GetOneInteger:_dictParas :@"degree" :1];
    self.img = [self blurryImage:self.img withBlurLevel:degree];
    if (self.img) {
        [_invokeResult SetResultBoolean:YES];
    }
    else
    {
        [_invokeResult SetResultBoolean:NO];
    }
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)toGrayScale:(NSArray *)parms
{
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    self.img = [self grayImage:self.img];
    if (self.img) {
        [_invokeResult SetResultBoolean:YES];
    }
    else
    {
        [_invokeResult SetResultBoolean:NO];
    }
    [_scritEngine Callback:_callbackName :_invokeResult];
}
- (void)toRoundCorner:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    NSString *_callbackName = [parms objectAtIndex:2];
    //回调函数名_callbackName
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    //参数字典_dictParas
    //自己的代码实现
    int radius = [doJsonHelper GetOneInteger:_dictParas :@"radius" :1];
    CGFloat imageW = self.img.size.width;
    CGFloat imageH = self.img.size.height;
    CGRect bounds = CGRectMake(0, 0, imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 1.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
    [path addClip];
    [self.img drawInRect:bounds];
    self.img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (self.img) {
        [_invokeResult SetResultBoolean:YES];
    }
    else
    {
        [_invokeResult SetResultBoolean:NO];
    }
    [_scritEngine Callback:_callbackName :_invokeResult];
}

- (void)getExif:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    
    NSString *source = [doJsonHelper GetOneText:_dictParas :@"source" :@""];
    if ([source isEqualToString:@""]) {
        return;
    }
    
    NSString *imgPath = [doIOHelper GetLocalFileFullPath:self.CurrentApp :source];
    NSURL *imageUrl = [NSURL fileURLWithPath:imgPath];
    
    CGImageSourceRef _imageRef = CGImageSourceCreateWithURL((CFURLRef)imageUrl, NULL);
    NSDictionary *_imageProperty = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(_imageRef, 0, NULL));
    
    NSDictionary *tiff = [_imageProperty objectForKey:@"{TIFF}"];
    NSDictionary *exif = [_imageProperty objectForKey:@"{Exif}"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (_imageProperty.allKeys.count>0) {
        id width = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"PixelXDimension"]]];
        id height = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"PixelYDimension"]]];
        id Make = [self checkEmpty:[tiff objectForKey:@"Make"]];
        id Model = [self checkEmpty:[tiff objectForKey:@"Model"]];
        double expTime = [[self checkEmpty:[exif objectForKey:@"ExposureTime"]] doubleValue];
        id ExposureTime = [NSString stringWithFormat:@"%0.4f",expTime];
        id FNumber = [self checkEmpty:[exif objectForKey:@"FNumber"]];
        id ISO = [exif objectForKey:@"ISOSpeedRatings"];
        if ([ISO isKindOfClass:[NSArray class]]) {
            ISO = [NSString stringWithFormat:@"%@",[[self checkEmpty:[exif objectForKey:@"ISOSpeedRatings"]] firstObject]];
        }
        else
        {
            ISO = @"";
        }
        id Date = [self checkEmpty:[exif objectForKey:@"DateTimeOriginal"]];
        id FocalLength = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"FocalLength"]]];
        id LensMake = [self checkEmpty:[exif objectForKey:@"LensMake"]];
        id LensModel = [self checkEmpty:[exif objectForKey:@"LensModel"]];
        id MeteringMode = [NSString stringWithFormat:@"%@",[self checkEmpty:[exif objectForKey:@"MeteringMode"]]];
        id LightSource = [self checkEmpty:[exif objectForKey:@"LightSource"]];
        
        [result setObject:width forKey:@"Width"];
        [result setObject:height forKey:@"Height"];
        [result setObject:Make forKey:@"Make"];
        [result setObject:Model forKey:@"Model"];
        [result setObject:ExposureTime forKey:@"ExposureTime"];
        [result setObject:FNumber forKey:@"FNumber"];
        [result setObject:ISO forKey:@"ISO"];
        [result setObject:Date forKey:@"Date"];
        [result setObject:FocalLength forKey:@"FocalLength"];
        [result setObject:LensMake forKey:@"LensMake"];
        [result setObject:LensModel forKey:@"LensModel"];
        [result setObject:MeteringMode forKey:@"MeteringMode"];
        [result setObject:LightSource forKey:@"LightSource"];
    }
    [_invokeResult SetResultNode:result];
}


# pragma mark - 私有方法
//高斯滤镜
- (UIImage *)blurryImage:(UIImage *)image
           withBlurLevel:(CGFloat)blur {
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage  *inputImage=[CIImage imageWithCGImage:image.CGImage];
    //设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(blur) forKey: @"inputRadius"];
    //模糊图片
    CIImage *result=[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage=[context createCGImage:result fromRect:inputImage.extent];
    UIImage *blurImage=[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}
//灰度滤镜
- (UIImage *)grayImage:(UIImage *)image
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef outImage = [context createCGImage:outputImage
                                        fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}
#pragma mark doIBitmap协议实现
- (void)setData:(UIImage *)_bitmap
{
    self.img = _bitmap;
}
- (UIImage *)getData
{
    return self.img;
}

- (id)checkEmpty:(id)obj
{
    if (!obj) {
        return @"";
    }
    return obj;
}


#pragma mark - 
- (void)addWatermark:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    NSString *_callbackName = [parms objectAtIndex:2];
    
    NSString *type = [doJsonHelper GetOneText:_dictParas :@"type" :@""];
    NSString *source = [doJsonHelper GetOneText:_dictParas :@"source" :@""];
    CGFloat percentX = [doJsonHelper GetOneInteger:_dictParas :@"percentX" :50]/100.0f;
    CGFloat percentY = [doJsonHelper GetOneInteger:_dictParas :@"percentY" :50]/100.0f;
    NSString *fontColor = [doJsonHelper GetOneText:_dictParas :@"fontColor" :@"000000FF"];
    NSString *fontStyle = [doJsonHelper GetOneText:_dictParas :@"fontStyle" :@"normal"];
    NSString *textFlag = [doJsonHelper GetOneText:_dictParas :@"textFlag" :@"normal"];
    NSInteger fontSize = [doJsonHelper GetOneInteger:_dictParas :@"fontSize" :17];
    
    if (type.length == 0) {
        return;
    }
    if ([source isEqualToString:@""]) {
        return;
    }
    //中心点

    UIImage *resultImg = nil;
    doUIModule *page = self.CurrentPage.RootView;
    CGFloat xzoom = page.XZoom;  CGFloat yzoom = page.YZoom;
    if ([type isEqualToString:@"image"]) {
        UIImage *image = nil;
        if ([source hasPrefix:@"source://"] || [source hasPrefix:@"data://"] ||[source hasPrefix:@"initdata://"]) {
            NSString * imagePath = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :source];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }else{
            doMultitonModule *_multitonModule = [doScriptEngineHelper ParseMultitonModule:_scritEngine :source];
            id<doIBitmap> bitmap = (id<doIBitmap>)_multitonModule;
            image = [bitmap getData];
        }
            
        
        CGPoint center = CGPointZero;
        center.x = self.img.size.width*percentX;
        center.y = self.img.size.height*percentY;
        
        CGFloat w = image.size.width*xzoom;
        CGFloat h = image.size.height*yzoom;
        
        CGRect r = CGRectMake(center.x - w/2, center.y - h/2, w, h);
        
        resultImg = [self addImage:self.img toImage:image withFrame:r];
    }else{
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.attributedText = [[NSAttributedString alloc] initWithString:source];
        
        //size
        if (fontSize) {
            int size = [doUIModuleHelper GetDeviceFontSize:fontSize :xzoom :yzoom];
            label.font = [UIFont systemFontOfSize:size];
        }
        //color
        if (fontColor) {
            UIColor *color = [doUIModuleHelper GetColorFromString:fontColor :[UIColor blackColor]];
            NSMutableAttributedString *content = [label.attributedText mutableCopy];
            [content beginEditing];
            NSRange contentRange = {0,[content length]};
            [content removeAttribute:NSForegroundColorAttributeName range:contentRange];
            [content addAttribute:NSForegroundColorAttributeName value:color range:contentRange];
            [content endEditing];
            label.attributedText = content;
        }
        //style
        if (fontStyle){
            float fontSize = label.font.pointSize;
            if([fontStyle isEqualToString:@"normal"])
            [label setFont:[UIFont systemFontOfSize:fontSize]];
            else if([fontStyle isEqualToString:@"bold"])
            [label setFont:[UIFont boldSystemFontOfSize:fontSize]];
            else if([fontStyle isEqualToString:@"italic"])
            {
                CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(FONT_OBLIQUITY * (CGFloat)M_PI / 180), 1, 0, 0);
                UIFontDescriptor *desc = [ UIFontDescriptor fontDescriptorWithName :[ UIFont systemFontOfSize :fontSize ]. fontName matrix :matrix];
                [label setFont:[ UIFont fontWithDescriptor :desc size :fontSize]];
            }
            else if([fontStyle isEqualToString:@"bold_italic"]){}
        }
        if (textFlag) {
            NSMutableAttributedString *content = [label.attributedText mutableCopy];
            [content beginEditing];
            NSRange contentRange = {0,[content length]};
            [content removeAttribute:NSUnderlineStyleAttributeName range:contentRange];
            [content removeAttribute:NSStrikethroughStyleAttributeName range:contentRange];
            if ([textFlag isEqualToString:@"normal" ]) {
                
            }else if ([textFlag isEqualToString:@"underline" ]) {
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            }else if ([textFlag isEqualToString:@"strikethrough" ]) {
//                [content addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                [content addAttributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle], NSBaselineOffsetAttributeName:@(NSUnderlineStyleSingle)} range:contentRange];
            }
            [content endEditing];
            label.attributedText = content;
        }
        
        if (label.attributedText.length>0) {
            CGFloat width = 9999,height = 9999;
            
            NSAttributedString *text = label.attributedText;
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:text];
            
            NSRange allRange = {0,[text length]};
            [attrStr addAttribute:NSFontAttributeName
                            value:label.font
                            range:allRange];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:label.textColor
                            range:allRange];
            
            NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine;
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, height)
                                                options:options
                                                context:nil];
            CGFloat widthR = CGRectGetWidth(rect);
            CGFloat heightR = ceilf(CGRectGetHeight(rect)) + 2;// 加两个像素,防止emoji被切掉.

            label.frame = CGRectMake(0, 0, widthR, heightR);
        }
        if (CGRectGetWidth(label.frame)>0) {
            CGRect r = label.frame;
            CGFloat w = r.size.width;
            CGFloat h = r.size.height;
            
            CGPoint center = CGPointZero;
            center.x = self.img.size.width*percentX;
            center.y = self.img.size.height*percentY;
            
            r = CGRectMake(center.x - w/2, center.y - h/2, w, h);
            resultImg = [self addImage:self.img toText:label withFrame:r];
        }
    }
    if (resultImg) {
        self.img = resultImg;
    }
    BOOL is = resultImg?YES:NO;
    doInvokeResult *invokeResult = [[doInvokeResult alloc] init];
    [invokeResult SetResultBoolean:is];
    [_scritEngine Callback:_callbackName :invokeResult];
}
- (UIImage *)addImage:(UIImage *)image1 toText:(UILabel *)label withFrame:(CGRect)rect{
//    UIGraphicsBeginImageContextWithOptions([image1 size], NO, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext([image1 size]);
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [label drawTextInRect:rect];

    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 withFrame:(CGRect)rect{
    UIGraphicsBeginImageContext([image1 size]);
//    UIGraphicsBeginImageContextWithOptions([image1 size], NO, [UIScreen mainScreen].scale);
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:rect];

    CGImageRef resultingImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;

    CGImageRef NewMergeImg = CGImageCreateWithImageInRect(resultingImage,CGRectMake(0, 0, image1.size.width, image1.size.height));

    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:NewMergeImg];
}
@end
