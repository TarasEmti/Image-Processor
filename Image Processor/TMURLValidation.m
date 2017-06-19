//
//  TMURLValidation.m
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMURLValidation.h"

@implementation TMURLValidation

+ (BOOL)isValidImageURL:(NSURL *) url {
    
    NSArray *validImageMIMETypes = @[@".gif", @"ico", @"jpeg", @"jpg", @".png", @".svg", @".tif", @".tiff", @"webp"];
    
    for (NSString* ext in validImageMIMETypes) {
        if ([[url path] hasSuffix:ext]) {
            return YES;
        }
    }
    return NO;
}

@end
