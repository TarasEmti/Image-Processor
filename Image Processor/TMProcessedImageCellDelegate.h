//
//  TMProcessedImageCellDelegate.h
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMProcessedImageCellDelegate <NSObject>

- (void)filterImplementationDoneInCell:(UITableViewCell *)cell;

@end
