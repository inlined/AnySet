//
//  SongDetailViewController.h
//  AnySet
//
//  Created by Héctor Ramos on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import "SongRequestTableViewController.h"

@interface SongDetailViewController : UIViewController<AVAudioPlayerDelegate>
@property (unsafe_unretained) IBOutlet SongRequestTableViewController *playlist;
@property (retain) PFObject *currentRequest;
@property (nonatomic, strong) IBOutlet UILabel *trackNameLabel;
@end
