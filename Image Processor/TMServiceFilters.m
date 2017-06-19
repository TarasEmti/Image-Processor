//
//  TMServiceFilters.m
//  Image Processor
//
//  Created by Тарас on 18.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMServiceFilters.h"

@implementation TMServiceFilters

+ (UIImage*) monochromeImage:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:ciimg forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) rotateImage:(UIImage*)image byDegrees:(int)degrees {
    
    float rotationAngle = - degrees * M_PI/180;
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
    [rotate setValue:ciimg forKey:kCIInputImageKey];
    
    CGAffineTransform t = CGAffineTransformMakeRotation(rotationAngle);
    [rotate setValue:[NSValue valueWithBytes:&t
                                    objCType:@encode(CGAffineTransform)]
              forKey:@"inputTransform"];
    
    CIImage *result = [rotate outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) horizontalMirrorImage:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
    [rotate setValue:ciimg forKey:kCIInputImageKey];
    
    CGAffineTransform t = CGAffineTransformMakeScale(-1, 1);
    
    [rotate setValue:[NSValue valueWithBytes:&t
                                    objCType:@encode(CGAffineTransform)]
              forKey:@"inputTransform"];
    
    CIImage *result = [rotate outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) invertColors:(UIImage*)image {
    
    CIImage *ciimg = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:ciimg forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
    
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    
    return resultImg;
}

+ (UIImage*) mirrorLeftHalf:(UIImage*)image {
    
    CGImageRef ciimg = image.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             CGImageGetWidth(ciimg),
                                             CGImageGetHeight(ciimg),
                                             CGImageGetBitsPerComponent(ciimg),
                                             CGImageGetBytesPerRow(ciimg),
                                             CGImageGetColorSpace(ciimg),
                                             CGImageGetBitmapInfo(ciimg));
    
    CGRect cropRect = CGRectMake(0,
                                 0,
                                 image.size.width/2,
                                 image.size.height);
    
    CGImageRef otherHalf = CGImageCreateWithImageInRect(ciimg, cropRect);
    
    CGContextDrawImage(ctx, CGRectMake(0,
                                       0,
                                       CGImageGetWidth(ciimg),
                                       CGImageGetHeight(ciimg)),
                       ciimg);
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(image.size.width, 0.0);
    t = CGAffineTransformScale(t, -1.0, 1.0);
    CGContextConcatCTM(ctx, t);
    CGContextDrawImage(ctx, cropRect, otherHalf);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    
    UIImage *resultImg = [UIImage imageWithCGImage:imageRef];
    
    return resultImg;
}

@end
