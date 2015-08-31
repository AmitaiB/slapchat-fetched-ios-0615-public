//
//  FISTableViewController.m
//  slapChat
//
//  Created by Joe Burgess on 6/27/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISTableViewController.h"
#import "Message.h"

@interface FISTableViewController ()
- (IBAction)addButtonTapped:(id)sender;

@end

@implementation FISTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.store = [FISDataStore sharedDataStore];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.store fetchData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.fetchedResultsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section. Use the standard(?) method of accessing section info from FRC-sectioninfo protocol.
    NSArray *sections = self.fetchedResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
//    return [self.store.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basiccell" forIndexPath:indexPath];
    
    Message *eachMessage = self.store.messages[indexPath.row];
    
    cell.textLabel.text = eachMessage.content;
    
    // Configure the cell...
    
    return cell;
}



#pragma mark - NSFetchedResultsController setup

    // We override the getter.
-(NSFetchedResultsController *)fetchedResultsController
{
        // If the controller is already set up, return it and grab a beer.
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
//    FRC will need to be associated with a fetch request:
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    NSManagedObjectContext *moc = self.store.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *chronoSort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    fetchRequest.sortDescriptors = @[chronoSort];
    
        // With our fetchRequest in hand, the FRC can be initialized.
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"createdAt" cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
        // With the FRC in hand, we can actually execute the fetch.
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error! %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
        //With that set up, it's time to implement the Delegate Protocol.
}

#pragma mark - NSFetchedResultsControllerDelegate methods

    //These two methods allow batching updates, instead of with every granular change. Simple.
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/**
 *  Not so simple.
 *
 *  @param controller   NSFetchedResultsController instance.
 *  @param anObject     NSManagedObject instance that changed.
 *  @param indexPath    the *current* index path of the record in the fetched results controller.
 *  @param type         the type of change, that is, *insert*, *update*, or *delete*.
 *  @param newIndexPath the new index path of the record in the fetched results controller, *after* the change.
 
 Note: These are not the tableview's indexPaths. See the delegate docs!
 */
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            /**
             *  Why not:
             [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
             atIndexPath:indexPath]; instead of reloadRows?
             ???
             */
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            default:
            NSLog(@"Did something go wrong??");
            break;
    }
}

#pragma mark

- (IBAction)addButtonTapped:(id)sender {
    Message *newTimestamp = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.store.managedObjectContext];
        //get a new object into an immutable array....
//    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.store.messages];
//    [temp addObject:newTimestamp];
//    self.store.messages = temp;
    
    NSUInteger currentMessageCount = self.store.messages.count;
    newTimestamp.content = [NSString stringWithFormat:@"Message %lu", currentMessageCount + 1];
    newTimestamp.createdAt = [NSDate date];
    
    [self.store saveContext];
    
    
}
@end
