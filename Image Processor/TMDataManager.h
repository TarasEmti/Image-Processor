//
//  TMDataManager.h
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TMDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSFetchRequest *fetchRequest;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (NSPersistentContainer *)persistentContainer;
- (NSArray *)getAllProcessedImages;
- (void)createProcessedImageEntity:(NSData *)data;
- (void)saveContext;

@end