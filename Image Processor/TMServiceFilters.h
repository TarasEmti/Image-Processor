//
//  TMServiceFilters.h
//  Image Processor
//
//  Created by Тарас on 18.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMServiceFilters : NSObject

+ (UIImage *)fixImageOrientation:(UIImage *)image;

+ (UIImage*) monochromeImage:(UIImage*)image;
+ (UIImage*) rotateImage:(UIImage*)image byDegrees:(int)degrees;
+ (UIImage*) horizontalMirrorImage:(UIImage*)image;
+ (UIImage*) invertColors:(UIImage*)image;
+ (UIImage*) mirrorLeftHalf:(UIImage*)image;

@end
