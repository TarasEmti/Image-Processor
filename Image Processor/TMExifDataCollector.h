//
//  TMExifDataCollector.h
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMExifInfoDelegate;

@interface TMExifDataCollector : NSObject

@property (assign, nonatomic) id delegate;

- (void)getExifDataFromURL:(NSURL*)fileURL;

@end

@protocol TMExifInfoDelegate <NSObject>

- (void)dataCollected:(NSDictionary*)exifData;

@end

