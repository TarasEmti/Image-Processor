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
#import "TMURLValidation.h"
#import "TMDownloadManager.h"
#import "TMExifDataCollector.h"
#import "TMExifTableViewController.h"

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

@property (strong, nonatomic) NSMutableArray *processedImages;
@property (strong, nonatomic) NSMutableDictionary *cellsState;
@property (nonatomic) UIButton *chooseImageButton;
@property (strong, nonatomic) UIProgressView *pickedImageDownloadProgress;
@property (strong, nonatomic) NSURL *pickedImageUrl;

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
    
    [self updateData];
    
    UIImage *loadedImage = [self loadPickedImage];
    
    if (loadedImage != nil) {
        [self.pickedImage setImage:loadedImage];
        [self activatePickedImageInteraction];
    } else {
        self.chooseImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.chooseImageButton setTitle:@"Choose image" forState:UIControlStateNormal];
        [self.chooseImageButton setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.f]];
        [self.chooseImageButton addTarget:self action:@selector(callChooseImageAlert:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.chooseImageButton];
    }
    _pickedImageDownloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:_pickedImageDownloadProgress];
}

- (void)viewDidLayoutSubviews {
    self.pickedImageHeight.constant = self.pickedImage.frame.size.width;
    [self.chooseImageButton setFrame:self.pickedImage.frame];
    
    [_pickedImageDownloadProgress setFrame:CGRectMake(CGRectGetMinX(_pickedImage.frame),
                                                      CGRectGetMaxY(_pickedImage.frame),
                                                      _pickedImage.frame.size.width,
                                                      3)];
    [_pickedImageDownloadProgress setHidden:YES];
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
    
    UIAlertAction *urlDownload = [UIAlertAction actionWithTitle:@"Download (URL)"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* _Nonnull action){
                                                       [self callAlertWithURLTextField];
                                                   }];
    [chooseimageAlert addAction:urlDownload];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [chooseimageAlert addAction:cancel];
    
    UIPopoverPresentationController *padActionController = [chooseimageAlert popoverPresentationController];
    if (padActionController ) {
        [padActionController setSourceView:self.view];
        [padActionController setSourceRect:self.pickedImage.frame];
    }
    
    [self presentViewController:chooseimageAlert animated:YES completion:nil];
}

- (void)callProcessedImageOptionsAlert:(id)sender {
    
    TMProcessedImageCell *cell = sender;
    
    UIAlertController *chooseActionAlert = [UIAlertController alertControllerWithTitle:@"Choose action"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *useImage = [UIAlertAction actionWithTitle:@"Use"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* _Nonnull action){
                                                         self.pickedImage.image = cell.processedImage.image;
                                                         self.pickedImageUrl = nil;
                                                         [self savePickedImage];
                                                         
                                                     }];
    [chooseActionAlert addAction:useImage];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction* _Nonnull action){
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
    
    UIPopoverPresentationController *padActionController = [chooseActionAlert popoverPresentationController];
    if (padActionController) {
        [padActionController setSourceView:cell.contentView];
        [padActionController setSourceRect:cell.contentView.frame];
    }
    
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

- (void)callAlertWithURLTextField {
    
    UIAlertController* urlAlert = [UIAlertController alertControllerWithTitle:@"Dowload From" message:@"Enter URL" preferredStyle:UIAlertControllerStyleAlert];
    
    [urlAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"http://somedomain.com/picture.jpg";
        [textField setReturnKeyType:UIReturnKeyGo];
    }];
    
    UIAlertAction* startDownload = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *urlEnter = urlAlert.textFields[0];
        NSString *urlText = [NSString stringWithString:urlEnter.text];
        NSURL *url = [NSURL URLWithString:urlText];
        
        if ((url != nil) && ([TMURLValidation isValidImageURL:url])) {
            [self downloadImageFromURL:url];
        } else {
            [self showStatusWithMessage:@"Wrong URL"];
        }
        [urlAlert dismissViewControllerAnimated:YES completion:nil];
    }];
    [urlAlert addAction:startDownload];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //[self resignFirstResponder];
    }];
    [urlAlert addAction:cancel];
    
    [self presentViewController:urlAlert animated:YES completion:nil];
}

//MARK: - Filter Buttons

- (IBAction)rotateButtonTouchUp:(id)sender {
    
    NSManagedObject *processedImage = [[self dataManager] createProcessedImageEntity];
    [_processedImages insertObject:processedImage atIndex:0];
    [self addRowInHistory];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        UIImage *filteredImage = [TMServiceFilters rotateImage:_pickedImage.image byDegrees:kRotateImageDegrees];
        [self setProcessedImage:filteredImage forObjectWith:[processedImage valueForKey:@"date"]];
    });
}

- (IBAction)invertColorsButtonTouchUp:(id)sender {
    
    NSManagedObject *processedImage = [[self dataManager] createProcessedImageEntity];
    [_processedImages insertObject:processedImage atIndex:0];
    [self addRowInHistory];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        UIImage *filteredImage = [TMServiceFilters invertColors:_pickedImage.image];
        [self setProcessedImage:filteredImage forObjectWith:[processedImage valueForKey:@"date"]];
    });
}

- (IBAction)horizontalMirrorButtonTouchUp:(id)sender {
    
    NSManagedObject *processedImage = [[self dataManager] createProcessedImageEntity];
    [_processedImages insertObject:processedImage atIndex:0];
    [self addRowInHistory];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        UIImage *filteredImage = [TMServiceFilters horizontalMirrorImage:_pickedImage.image];
        [self setProcessedImage:filteredImage forObjectWith:[processedImage valueForKey:@"date"]];
    });
}

- (IBAction)monochromeButtonTouchUp:(id)sender {
    
    NSManagedObject *processedImage = [[self dataManager] createProcessedImageEntity];
    [_processedImages insertObject:processedImage atIndex:0];
    [self addRowInHistory];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        UIImage *filteredImage = [TMServiceFilters monochromeImage:_pickedImage.image];
        [self setProcessedImage:filteredImage forObjectWith:[processedImage valueForKey:@"date"]];
    });
}

- (IBAction)mirrorLeftHalfTouchUp:(id)sender {
    
    NSManagedObject *processedImage = [[self dataManager] createProcessedImageEntity];
    [_processedImages insertObject:processedImage atIndex:0];
    [self addRowInHistory];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        UIImage *filteredImage = [TMServiceFilters mirrorLeftHalf:_pickedImage.image];
        [self setProcessedImage:filteredImage forObjectWith:[processedImage valueForKey:@"date"]];
    });
}

//MARK: - DataManager operations

- (TMDataManager*)dataManager {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return (TMDataManager*)appDelegate.dataManager;
}

- (void)setProcessedImage:(UIImage *)image forObjectWith:(NSDate *)date  {
    
    NSManagedObject* processedImage = [[self dataManager] getProceesedImageWithDate:date];
    
    if (processedImage) {
        NSData *data = UIImageJPEGRepresentation(image, 1.f);
        [processedImage setValue:data forKey:@"imageData"];
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
        [dataManager saveCurrentPicture:imageData withUrl:self.pickedImageUrl];
    }
}

- (UIImage *)loadPickedImage {
    
    TMDataManager *dataManager = [self dataManager];
    NSManagedObject *pickedImage = [dataManager getCurrentPicture];
    
    NSString *assetUrlString = [pickedImage valueForKey:@"imageUrl"];
    NSURL *assetUrl = [NSURL URLWithString:assetUrlString];
    self.pickedImageUrl = assetUrl;
    
    NSData *imageData = [pickedImage valueForKey:@"imageData"];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    return image;
}

//MARK: - Checking cell state

- (BOOL)cellIsLoading:(NSIndexPath *)indexPath {
    NSNumber *loadingState = [_cellsState objectForKey:indexPath];
    return loadingState == nil ? NO : [loadingState boolValue];
}

//MARK: - Download Operations

- (void)downloadImageFromURL:(NSURL *)url {
    TMDownloadManager *manager = [[TMDownloadManager alloc] init];
    manager.delegate = self;
    
    [manager downloadImageFromURL:url];
    
    [_pickedImageDownloadProgress setProgress:0.f];
    [_pickedImageDownloadProgress setHidden:NO];
}

- (void)imageDidLoad:(UIImage*)image toURL:(NSURL*)url {
    
    [_pickedImageDownloadProgress setHidden:YES];
    [self.pickedImage setImage:image];
    self.pickedImageUrl = url;
    [self savePickedImage];
}

- (void)progressChanged:(float)progress {
    [_pickedImageDownloadProgress setProgress:progress];
}

//MARK: - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _processedImages.count;
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMProcessedImageCell* processedImageCell = [tableView dequeueReusableCellWithIdentifier:@"processedImageCell"];
    processedImageCell.delegate = self;
    
    if ([self cellIsLoading:indexPath]) {
        [processedImageCell showLoadingState];
    } else {
        [processedImageCell hideLoadingState];
    }
    NSData *imageData = [self.processedImages[indexPath.row] valueForKey:@"imageData"];
    if (imageData) {
        UIImage *processedImage = [UIImage imageWithData:imageData];
        processedImageCell.processedImage.image = processedImage;
    }
    
    return processedImageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TMProcessedImageCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell.isLoading) {
        return;
    } else {
        [self callProcessedImageOptionsAlert:selectedCell];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellIsLoading:indexPath] ? kCellLoadingHeight : kCellLoadedHeight;
}

//MARK: - History Table view changes

- (void)addRowInHistory {
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.historyTableView beginUpdates];
        [self.historyTableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationTop];
        [self.historyTableView endUpdates];
        
        [self.historyTableView beginUpdates];
        TMProcessedImageCell *newCell = [_historyTableView cellForRowAtIndexPath:index];
        [newCell startTimer];
        [self updateCellsState];
        [self.historyTableView endUpdates];
}

- (void)deleteRowInHistory:(NSIndexPath *)index {
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        [self updateData];
        
        [self.historyTableView beginUpdates];
        [self.historyTableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationRight];
        [self updateCellsState];
        [self.historyTableView endUpdates];
    });
}

// Most time expensive method
- (void)updateData {
    
    TMDataManager *dataManager = [self dataManager];
    NSArray *freshImagesHistory = [dataManager getAllProcessedImages];
    self.processedImages = [NSMutableArray arrayWithArray:freshImagesHistory];
}

- (void)updateCellsState {
    
    for (int i= 0; i < _processedImages.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        TMProcessedImageCell *cell = [_historyTableView cellForRowAtIndexPath:index];
        NSNumber *state = [NSNumber numberWithBool:cell.isLoading];
        [_cellsState setObject:state forKey:index];
    }
}

- (void)filterImplementationDoneInCell:(UITableViewCell *)cell {
    
    [[self dataManager] saveContext];
    
    [self updateCellsState];
    
    [self.historyTableView beginUpdates];
    [self.historyTableView endUpdates];
    
    [self.historyTableView reloadData];
}

//MARK: - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.pickedImage setImage:chosenImage];
    self.pickedImageUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    [self savePickedImage];
    
    if (!_chooseImageButton.hidden) {
        [self.chooseImageButton setHidden:YES];
        [self activatePickedImageInteraction];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//MARK: - Show EXIF data

- (IBAction)exifDataTouchUp:(id)sender {
    
    if (self.pickedImageUrl) {
        
        TMExifDataCollector *collector = [[TMExifDataCollector alloc] init];
        collector.delegate = self;
        [collector getExifDataFromURL:self.pickedImageUrl];
    }
}

- (void)dataCollected:(NSDictionary*)exifData {
    TMExifTableViewController* exifView = [[TMExifTableViewController alloc] initWithExifDict:exifData];
    [self showViewController:exifView sender:self];
}

//MARK: - Saving image to galery

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self showStatusWithMessage:@"Saved"];
}

- (void)showStatusWithMessage:(NSString *)message {
    
    UILabel* okWidndow = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100)];
    
    okWidndow.layer.cornerRadius = 10;
    okWidndow.layer.masksToBounds = YES;
    
    okWidndow.text = message;
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
