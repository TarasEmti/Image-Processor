//
//  TMProcessedImageCell.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMProcessedImageCell.h"

@interface TMProcessedImageCell()

@property (nonatomic) NSTimer *timer;
@property (assign) int loadingDelay;
@property (assign) int timePassed;

@end

@implementation TMProcessedImageCell

@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    [_progressBar setHidden:YES];
    
    _isLoading = NO;
}

- (void)showLoadingState {
    [_progressBar setHidden:NO];
    [_processedImage setHidden:YES];
}

- (void)startTimer {
    _isLoading = YES;
    
    _loadingDelay = arc4random() % 25 + 5;
    _timePassed = 0;
    
    [_progressBar setProgress:0.f];
    [self showLoadingState];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.0167 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)timerTick {
    _timePassed += 1;
    
    float seconds = _timePassed / 60;
    if (seconds <= _loadingDelay) {
        [_progressBar setProgress:(seconds / _loadingDelay)];
    } else {
        [self timerEnds];
    }
}

- (void)timerEnds {
    [self.timer invalidate];
    self.timer = nil;
    
    _isLoading = NO;
    [self hideLoadingState];
    [delegate filterImplementationDoneInCell:self];
}

- (void)hideLoadingState {
    [_progressBar setHidden:YES];
    [_processedImage setHidden:NO];
}

@end
