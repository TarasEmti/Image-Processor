//
//  TMFilterButton.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMFilterButton.h"

@implementation TMFilterButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.layer setBorderWidth:1.f];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
}

@end
