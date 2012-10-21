//
//  CPMasterViewController.h
//  iOS application
//
//  Created by Fabio Pelosin on 09/10/12.
//  Copyright (c) 2012 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface CPMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
