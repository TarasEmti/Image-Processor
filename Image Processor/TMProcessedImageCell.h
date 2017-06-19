//
//  TMProcessedImageCell.h
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMProcessedImageCellDelegate.h"

@protocol TMProcessedImageCellDelegate;

@interface TMProcessedImageCell : UITableViewCell

@property (assign, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet UIImageView *processedImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (assign) BOOL isLoading;

- (void)showLoadingState;
- (void)hideLoadingState;
- (void)startTimer;

@end
