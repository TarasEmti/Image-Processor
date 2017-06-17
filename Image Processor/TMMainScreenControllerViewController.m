//
//  TMMainScreenControllerViewController.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMMainScreenControllerViewController.h"
#import "TMFilterButton.h"

@interface TMMainScreenControllerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *pickedImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickedImageHeight;
@property (weak, nonatomic) IBOutlet UIButton *exifDataButton;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet TMFilterButton *rotateButton;
@property (weak, nonatomic) IBOutlet TMFilterButton *invertColorsButton;
@property (weak, nonatomic) IBOutlet TMFilterButton *mirrorButton;
@property (weak, nonatomic) IBOutlet TMFilterButton *monochromeButton;
@property (weak, nonatomic) IBOutlet TMFilterButton *mirrorLeftHalfButton;

@end

@implementation TMMainScreenControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle: @"Image Processor"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Somehow, this image resize won't work in viewWillAppear, so, whatever.
    //Adjust picked image frame here, so it will be a square form on a view.
    _pickedImageHeight.constant = _pickedImage.frame.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rotateButtonTouchUp:(id)sender {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
