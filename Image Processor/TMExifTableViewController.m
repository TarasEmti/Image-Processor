//
//  TMExifTableViewController.m
//  Image Processor
//
//  Created by Тарас on 19.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMExifTableViewController.h"

@interface TMExifTableViewController ()

@property (strong, nonatomic) NSArray *keysExif;
@property (strong, nonatomic) NSDictionary* exif;

@end

@implementation TMExifTableViewController

- (id)initWithExifDict:(NSDictionary*)exifDict {
    self = [super init];
    
    self.exif = exifDict;
    NSArray* keysArray = [exifDict allKeys];
    self.keysExif = [keysArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"EXIF Data"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.keysExif count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    NSString *option = [NSString stringWithFormat:@"%@", [_keysExif objectAtIndex:indexPath.row]];
    NSString *detail = [NSString stringWithFormat:@"%@", [_exif valueForKey:[_keysExif objectAtIndex:indexPath.row]]];
    NSString *detailClean = [detail stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    cell.textLabel.text = option;
    cell.detailTextLabel.text = [detailClean stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return cell;
}

// MARK: - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
