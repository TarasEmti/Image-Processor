//
//  TMProcessedImageCell.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMProcessedImageCell.h"

@implementation TMProcessedImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_progressBar setHidden:YES];
}

@end
