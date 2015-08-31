//
//  FISTableViewController.h
//  slapChat
//
//  Created by Joe Burgess on 6/27/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FISDataStore.h"


@interface FISTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSArray *managedMessageObjects;
@property (strong, nonatomic) FISDataStore *store;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
