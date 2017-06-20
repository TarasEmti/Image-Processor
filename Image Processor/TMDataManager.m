//
//  TMDataManager.m
//  Image Processor
//
//  Created by Тарас on 17.06.17.
//  Copyright © 2017 Taras Minin. All rights reserved.
//

#import "TMDataManager.h"

@implementation TMDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchRequest = _fetchRequest;
@synthesize persistentContainer = _persistentContainer;

- (NSManagedObject *)getCurrentPicture {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (context != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TMPickedImage"
                                       inManagedObjectContext:_persistentContainer.viewContext];
        [fetchRequest setEntity:entity];
        
        NSError *requestError = nil;
        NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
        if (resultArray.count > 0) {
            NSManagedObject *currentImage = [resultArray lastObject];
            return currentImage;
        }
    }
    return nil;
}

- (BOOL)saveCurrentPicture:(NSData *)imageData withUrl:(NSURL *)url {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context != nil) {
        NSManagedObject *image = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"TMPickedImage"
                                  inManagedObjectContext: context];
        [image setValue:imageData forKey:@"imageData"];
        
        NSString *urlString = [url absoluteString];
        [image setValue:urlString forKey:@"imageUrl"];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        return YES;
    }
    return NO;
}

- (NSArray *)getAllProcessedImages {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (context != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TMProcessedImage"
                                       inManagedObjectContext:_persistentContainer.viewContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"date"
                                            ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        NSError *requestError = nil;
        NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&requestError];
        if (requestError) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
        return resultArray;
    }
    return nil;
}

- (NSManagedObject *)createProcessedImageEntity {
    
    //Something to create entity here
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context != nil) {
        NSManagedObject *processedImage = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"TMProcessedImage"
                                  inManagedObjectContext: context];
        [processedImage setValue:nil forKey:@"imageData"];
        NSDate *time = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        [processedImage setValue:time forKey:@"date"];
        
        return processedImage;
    }
    return nil;
}

- (BOOL)deleteProcessedImageEntity:(NSManagedObject *)entity {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context != nil) {
        [context deleteObject:entity];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        return YES;
    }
    return NO;
}

- (NSManagedObject *)getProceesedImageWithDate:(NSDate *)date {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (context != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TMProcessedImage"
                                       inManagedObjectContext:_persistentContainer.viewContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
        [fetchRequest setPredicate:predicate];
        
        NSError *requestError = nil;
        NSArray *resultArray = [context executeFetchRequest:fetchRequest error:&requestError];
        if ((requestError) || (resultArray.count != 1)) {
            NSLog(@"%@", [requestError localizedDescription]);
        }
        
        return [resultArray firstObject];
    }
    return nil;
}

#pragma mark - Core Data stack

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Image_Processor"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
