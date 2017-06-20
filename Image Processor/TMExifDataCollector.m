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
#import <Photos/Photos.h>

@implementation TMExifDataCollector

@synthesize delegate;

- (void)getExifDataFromURL:(NSURL *)fileURL {
    
    PHFetchResult *assets = [PHAsset fetchAssetsWithALAssetURLs:@[fileURL] options:nil];
    PHAsset *asset = [assets firstObject];
    
    PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
    
    
    
    [asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
        
        CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
        NSDictionary *properties = fullImage.properties;
        NSDictionary *exifData = [properties valueForKey:@"{Exif}"];
        [delegate dataCollected:exifData];
    }];
}

@end
