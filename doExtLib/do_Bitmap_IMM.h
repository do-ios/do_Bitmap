//
//  do_Bitmap_MM.h
//  DoExt_MM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_Bitmap_IMM <NSObject>
//实现同步或异步方法，parms中包含了所需用的属性
- (void)loadFile:(NSArray *)parms;
- (void)save:(NSArray *)parms;
- (void)toFrostedGlass:(NSArray *)parms;
- (void)toGrayScale:(NSArray *)parms;
- (void)toRoundCorner:(NSArray *)parms;
- (void)getExif:(NSArray *)parms;
- (void)addWatermark:(NSArray *)parms;
@end