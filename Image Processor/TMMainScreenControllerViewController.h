//
//  TMMainScreenControllerViewController.h
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMProcessedImageCellDelegate.h"

@interface TMMainScreenControllerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TMProcessedImageCellDelegate>

@end
