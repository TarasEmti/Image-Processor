//
//  TMMainScreenControllerViewController.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMMainScreenControllerViewController.h"
#import "TMFilterButton.h"
#import "TMProcessedImageCell.h"

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

@property (strong, nonatomic) NSArray *processedImages;
@property (strong, nonatomic) NSMutableDictionary *cellsState;
@end

@implementation TMMainScreenControllerViewController

#define kCellLoadingHeight 25.f
#define kCellLoadedHeight 200.f

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle: @"Image Processor"];
    [self.historyTableView setTableFooterView:[[UIView alloc] init]];
    
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    
    NSArray *testArray = [[NSArray alloc] initWithObjects:@"12", @"asd", nil];
    _processedImages = testArray;
    _cellsState = [[NSMutableDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Somehow, this image resize won't work in viewWillAppear, so, whatever.
    //Adjust picked image frame here, so it will be a square form on a view.
    _pickedImageHeight.constant = _pickedImage.frame.size.width;
}

- (IBAction)rotateButtonTouchUp:(id)sender {
    
}

- (BOOL)cellIsLoading:(NSIndexPath *)indexPath {
    
    NSNumber *loadingState = [_cellsState objectForKey:indexPath];
    NSLog(@"loading state %@", loadingState);
    return loadingState == nil ? NO : [loadingState boolValue];
}

//MARK: - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _processedImages.count;
}

//MARK: - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMProcessedImageCell* processedImageCell = [tableView dequeueReusableCellWithIdentifier:@"processedImageCell"];
    //processedImageCell.processedImage.image = self.processedImages[indexPath.row];
    
    return processedImageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TMProcessedImageCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL isLoading = ![self cellIsLoading:indexPath];
    [selectedCell.progressBar setHidden: !selectedCell.progressBar.isHidden];
    [selectedCell.processedImage setHidden: !selectedCell.processedImage.isHidden];
    
    NSNumber *loadingState = [NSNumber numberWithBool:isLoading];
    [_cellsState setObject:loadingState forKey:indexPath];
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"before height %d", [self cellIsLoading:indexPath]);
    return [self cellIsLoading:indexPath] ? kCellLoadingHeight : kCellLoadedHeight;
}

@end
