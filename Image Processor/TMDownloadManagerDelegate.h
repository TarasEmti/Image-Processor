//
//  TMDownloadManagerDelegate.h
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TMDownloadManagerDelegate <NSObject>

- (void)imageDidLoad:(UIImage*)image toURL:(NSURL*)url;
- (void)progressChanged:(float)progress;

@end
