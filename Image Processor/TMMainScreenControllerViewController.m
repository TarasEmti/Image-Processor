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
#define kRotateImageDegrees 90

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle: @"Image Processor"];
    [self.historyTableView setTableFooterView:[[UIView alloc] init]];
    
    //Small tableView customization
    [_historyTableView.layer setBorderWidth: 0.5];
    [_historyTableView.layer setBorderColor:[UIColor blackColor].CGColor];
    [_historyTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_historyTableView setSeparatorInset:UIEdgeInsetsMake(8, 0, 8, 0)];
    
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    
    _cellsState = [[NSMutableDictionary alloc] init];
    
    TMDataManager *dataManager = [self dataManager];
    NSArray *freshImagesHistory = [dataManager getAllProcessedImages];
    self.processedImages = freshImagesHistory;
    
    UIImage *loadedImage = [self loadPickedImage];
    
    if (loadedImage != nil) {
        [self.pickedImage setImage:loadedImage];
        [self activatePickedImageInteraction];
    } else {
        self.chooseImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.chooseImageButton setTitle:@"Choose image" forState:UIControlStateNormal];
        [self.chooseImageButton setBackgroundColor:[UIColor lightGrayColor]];
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

- (void)callProcessedImageOptionsAlert:(id)sender {
    
    UIAlertController *chooseActionAlert = [UIAlertController alertControllerWithTitle:@"Choose action"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *useImage = [UIAlertAction actionWithTitle:@"Use"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction* _Nonnull action){
                                                             TMProcessedImageCell *cell = sender;
                                                             self.pickedImage.image = cell.processedImage.image;
                                                             [self savePickedImage];
                                                             
                                                         }];
    [chooseActionAlert addAction:useImage];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* _Nonnull action){
                                                       TMProcessedImageCell *cell = sender;
                                                       UIImage *processedImage = cell.processedImage.image;
                                                       UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                                   }];
    [chooseActionAlert addAction:save];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction* _Nonnull action){
                                                       [self deleteProcessedImage:sender];
                                                   }];
    [chooseActionAlert addAction:delete];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [chooseActionAlert addAction:cancel];
    
    [self presentViewController:chooseActionAlert animated:YES completion:nil];
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

//MARK: - Filter Buttons

- (IBAction)rotateButtonTouchUp:(id)sender {
    UIImage *filteredImage = [TMServiceFilters rotateImage:_pickedImage.image byDegrees:kRotateImageDegrees];
    [self createProcessedImage:filteredImage];
}

- (IBAction)invertColorsButtonTouchUp:(id)sender {
    UIImage *filteredImage = [TMServiceFilters invertColors:_pickedImage.image];
    [self createProcessedImage:filteredImage];
}

- (IBAction)horizontalMirrorButtonTouchUp:(id)sender {
    UIImage *filteredImage = [TMServiceFilters horizontalMirrorImage:_pickedImage.image];
    [self createProcessedImage:filteredImage];
}

- (IBAction)monochromeButtonTouchUp:(id)sender {
    UIImage *filteredImage = [TMServiceFilters monochromeImage:_pickedImage.image];
    [self createProcessedImage:filteredImage];
}

- (IBAction)mirrorLeftHalfTouchUp:(id)sender {
    UIImage *filteredImage = [TMServiceFilters mirrorLeftHalf:_pickedImage.image];
    [self createProcessedImage:filteredImage];
}

//MARK: - DataManager operations

- (TMDataManager*)dataManager {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return (TMDataManager*)appDelegate.dataManager;
}

- (void)createProcessedImage:(UIImage *)image {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    if (imageData.bytes != nil) {
        TMDataManager *dataManager = [self dataManager];
        if ([dataManager createProcessedImageEntity:imageData]) {
            [self addRowInHistory];
        }
    }
}

- (void)deleteProcessedImage:(id)sender {
    
    TMProcessedImageCell *cell = sender;
    if (cell) {
        NSIndexPath *cellIndexPath = [_historyTableView indexPathForCell:cell];
        NSManagedObject *processedImage = self.processedImages[cellIndexPath.row];
        TMDataManager *dataManager = [self dataManager];
        if ([dataManager deleteProcessedImageEntity:processedImage]) {
            [self deleteRowInHistory:cellIndexPath];
        }
    }
}

- (void)savePickedImage {
    
    NSData *imageData = UIImageJPEGRepresentation(self.pickedImage.image, 1.f);
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

//MARK: - Checking cell state

- (BOOL)cellIsLoading:(NSIndexPath *)indexPath {
    NSNumber *loadingState = [_cellsState objectForKey:indexPath];
    return loadingState == nil ? NO : [loadingState boolValue];
}

//MARK: - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _processedImages.count;
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMProcessedImageCell* processedImageCell = [tableView dequeueReusableCellWithIdentifier:@"processedImageCell"];
    NSData *imageData = [self.processedImages[indexPath.row] valueForKey:@"imageData"];
    UIImage *processedImage = [UIImage imageWithData:imageData];
    processedImageCell.processedImage.image = processedImage;
    
    return processedImageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self cellIsLoading:indexPath]) {
        return;
    } else {
        TMProcessedImageCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [self callProcessedImageOptionsAlert:selectedCell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellIsLoading:indexPath] ? kCellLoadingHeight : kCellLoadedHeight;
}

//MARK: - History Table view changes

- (void)addRowInHistory {
    
    [self updateData];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.historyTableView beginUpdates];
    [self.historyTableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationTop];
    [self.historyTableView endUpdates];
}

- (void)deleteRowInHistory:(NSIndexPath *)index {
    
    [self updateData];
    
    [self.historyTableView beginUpdates];
    [self.historyTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationLeft];
    [self.historyTableView endUpdates];
}

- (void)updateData {
    
    TMDataManager *dataManager = [self dataManager];
    NSArray *freshImagesHistory = [dataManager getAllProcessedImages];
    self.processedImages = freshImagesHistory;
}

//MARK: - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.pickedImage setImage:chosenImage];
    [self savePickedImage];
    
    if (!_chooseImageButton.hidden) {
        [self.chooseImageButton setHidden:YES];
        [self activatePickedImageInteraction];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//MARK: - Saving image to galery

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    UILabel* okWidndow = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100)];
    
    okWidndow.layer.cornerRadius = 10;
    okWidndow.layer.masksToBounds = YES;
    
    okWidndow.text = @"OK";
    okWidndow.textAlignment = NSTextAlignmentCenter;
    okWidndow.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [[self view] addSubview:okWidndow];
    
    [UIView animateWithDuration:2
                          delay:1
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         okWidndow.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [okWidndow setHidden:finished];
                     }];
}

@end
