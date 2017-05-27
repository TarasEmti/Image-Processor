//
//  AppDelegate.h
//  Image Processor
//
//  Created by Тарас on 27.05.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

