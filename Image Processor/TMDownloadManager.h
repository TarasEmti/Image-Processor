//
//  TMDownloadManager.h
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMDownloadManagerDelegate;

@interface TMDownloadManager : NSObject <NSURLSessionDownloadDelegate>

@property (nonatomic, assign) id  delegate;

- (void)downloadImageFromURL:(NSURL*)url;

@end
