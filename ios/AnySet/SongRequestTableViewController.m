//
// This is the template PFQueryTableViewController subclass file. Use it to customize your own subclass.
//

#import "SongRequestTableViewController.h"

@interface SongRequestTableViewController()
@property (nonatomic, assign) BOOL isEmpty;
@end

@implementation SongRequestTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.className = @"Request";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"song";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        self.isEmpty = YES;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Request Queue";
    NSLog(@"Loaded");
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (self.isEmpty && self.objects.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noLongerEmpty" object:nil];
    }
    
    self.isEmpty = self.objects.count == 0;
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query includeKey:@"listener"];
    [query whereKey:@"played" notEqualTo:@YES];
    
    [query orderByDescending:@"karma"];
    [query addAscendingOrder:@"createdAt"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    PFObject *listener = [object objectForKey:@"listener"];
    NSString *nick = [listener objectForKey:@"nick"];
    
    // Configure the cell
    cell.textLabel.text = [object objectForKey:self.textKey];
    
    if (nick && nick.length > 0) {
        cell.detailTextLabel.text = nick;
    } else {
        cell.detailTextLabel.text = @"Anon";
    }
    
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *popupSheet = [[UIActionSheet alloc] init];
    popupSheet.tag = indexPath.row;
    popupSheet.delegate = self;
    [popupSheet addButtonWithTitle:@"Bump!"];
    popupSheet.destructiveButtonIndex = [popupSheet addButtonWithTitle:@"Remove"];
    popupSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *accessoryView = nil;
    for (UIView *subview in cell.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            accessoryView = subview;
            break;
        }
    }
    
    [popupSheet showFromRect:accessoryView.bounds inView:accessoryView animated:YES];
}

#pragma mark - UITableViewDataSource

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the object from Parse and reload the table view
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, and save it to Parse
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    PFObject *request = [self.objects objectAtIndex:actionSheet.tag];
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        // Remove from Queue
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self loadObjects];
            }
        }];
    } else {
        // Bump
        if (self.objects.count > 1) {
            PFObject *currentRequest = [self.objects objectAtIndex:0];
            PFObject *nextRequest = [self.objects objectAtIndex:1];
            NSNumber *topKarma = [nextRequest objectForKey:@"karma"];
            NSNumber *newKarma = [NSNumber numberWithInt:topKarma.intValue + 1];
            [request setObject:newKarma forKey:@"karma"];
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [currentRequest deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self loadObjects];
                }];
            }];
        }
    }
}

@end