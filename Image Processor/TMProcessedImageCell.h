//
//  TMProcessedImageCell.h
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMProcessedImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *processedImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end
