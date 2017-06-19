//
//  TMExifDataCollector.m
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMExifDataCollector.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation TMExifDataCollector

@synthesize delegate;

+ (NSDictionary*)getExifDataFromURL:(NSURL *)fileURL {
    
    CGImageSourceRef mySourceRef = CGImageSourceCreateWithURL((CFURLRef)fileURL, NULL);
    NSDictionary *myMetadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL));
    NSDictionary *exifDict = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    
    return exifDict;
}
/*
 + (void)modifyEXIFdata:(NSDictionary*)exifData {
 
 
 }
 */
@end
