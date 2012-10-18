//
//  SongDetailViewController.h
//  AnySet
//
//  Created by Héctor Ramos on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import "SongRequestTableViewController.h"

@interface SongDetailViewController : UIViewController
@property (unsafe_unretained) IBOutlet SongRequestTableViewController *playlist;
@property (retain) PFObject *currentRequest;
@end
