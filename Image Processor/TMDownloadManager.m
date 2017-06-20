//
//  TMDownloadManager.m
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMDownloadManager.h"
#import "TMDownloadManagerDelegate.h"

@interface TMDownloadManager ()

@property (strong, nonatomic) NSURL* url;

@end

@implementation TMDownloadManager

@synthesize delegate;

- (void)downloadImageFromURL:(NSURL*)url {
    
    _url = url;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    [[session downloadTaskWithURL:url] resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        [delegate progressChanged:progress];
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    NSURL *documentsDirectory = [urls firstObject];
    NSURL *originalUrl = [NSURL URLWithString:[_url lastPathComponent]];
    NSURL *destinationUrl = [documentsDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    
    NSError *fileManagerError;
    
    [fileManager removeItemAtURL:destinationUrl error:NULL];
    
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&fileManagerError];
    
    NSData *data = [NSData dataWithContentsOfURL:destinationUrl];
    UIImage *image = [UIImage imageWithData:data];
    
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [delegate imageDidLoad:image toURL:destinationUrl];
        });
    }
}

@end
