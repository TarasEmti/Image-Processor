//
//  TMMainScreenControllerViewController.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMMainScreenControllerViewController.h"
#import "AppDelegate.h"
#import "TMFilterButton.h"
#import "TMServiceFilters.h"
#import "TMProcessedImageCell.h"
#import "TMDataManager.h"

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
@property (nonatomic) UIButton *chooseImageButton;

@end

@implementation TMMainScreenControllerViewController

#define kCellLoadingHeight 30.f
#define kCellLoadedHeight 200.f

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle: @"Image Processor"];
    [self.historyTableView setTableFooterView:[[UIView alloc] init]];
    
    //Small tableView customization
    [_historyTableView.layer setBorderWidth: 1.f];
    [_historyTableView.layer setBorderColor:[UIColor blackColor].CGColor];
    [_historyTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_historyTableView setSeparatorInset:UIEdgeInsetsMake(8, 0, 8, 0)];
    
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    
    _cellsState = [[NSMutableDictionary alloc] init];
    
    [self updateData];
    
    UIImage *loadedImage = [self loadPickedImage];
    if (loadedImage != nil) {
        [self.pickedImage setImage:loadedImage];
        [self activatePickedImageInteraction];
    } else {
        self.chooseImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.chooseImageButton setTitle:@"Choose image" forState:UIControlStateNormal];
        [self.chooseImageButton addTarget:self action:@selector(callChooseImageAlert:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.chooseImageButton];
    }
}

- (void)viewDidLayoutSubviews {
    self.pickedImageHeight.constant = self.pickedImage.frame.size.width;
    [self.chooseImageButton setFrame:self.pickedImage.frame];
}

- (void)activatePickedImageInteraction {
    [self.pickedImage setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callChooseImageAlert:)];
    [self.pickedImage addGestureRecognizer:tapRecognizer];
}

- (void)callChooseImageAlert:(id)sender {
    
    UIAlertController *chooseimageAlert = [UIAlertController alertControllerWithTitle:@"Choose source"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *photoGallery = [UIAlertAction actionWithTitle:@"Photo Gallery"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction* _Nonnull action){
                                                             [self callImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                         }];
    [chooseimageAlert addAction:photoGallery];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* _Nonnull action){
                                                       [self callImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                                                         }];
    [chooseimageAlert addAction:camera];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [chooseimageAlert addAction:cancel];
    
    [self presentViewController:chooseimageAlert animated:YES completion:nil];
}

- (void)callImagePickerWithSourceType:(UIImagePickerControllerSourceType)source {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:source]) {
        [picker setSourceType:source];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"Sorry, use real device");
    }
}

- (void)updateData {
    
    TMDataManager *dataManager = [self dataManager];
    
    NSArray *freshImagesHistory = [dataManager getAllProcessedImages];
    self.processedImages = freshImagesHistory;
    
    [self.historyTableView reloadData];
}

// MARK: - Filter Buttons

- (IBAction)rotateButtonTouchUp:(id)sender {
    
}

// MARK: - DataManager operations

- (TMDataManager*)dataManager {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return (TMDataManager*)appDelegate.dataManager;
}

- (void)createProcessedImage:(UIImage *)image {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    if (imageData.bytes != nil) {
        TMDataManager *dataManager = [self dataManager];
        if ([dataManager createProcessedImageEntity:imageData]) {
            [self updateData];
        }
    }
}

- (void)savePickedImage:(UIImage *)image {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    if (imageData.bytes != nil) {
        TMDataManager *dataManager = [self dataManager];
        [dataManager setCurrentPicture:imageData];
    }
}

- (UIImage *)loadPickedImage {
    
    TMDataManager *dataManager = [self dataManager];
    NSData *imageData = [dataManager getCurrentPicture];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    return image;
}

- (BOOL)cellIsLoading:(NSIndexPath *)indexPath {
    
    NSNumber *loadingState = [_cellsState objectForKey:indexPath];
    NSLog(@"loading state %@", loadingState);
    return loadingState == nil ? NO : [loadingState boolValue];
}

//MARK: -UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _processedImages.count;
}

//MARK: -UITableViewDataSource

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

//MARK: -UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.pickedImage setImage:chosenImage];
    [self savePickedImage:chosenImage];
    
    if (!_chooseImageButton.hidden) {
        [self.chooseImageButton setHidden:YES];
        [self activatePickedImageInteraction];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
