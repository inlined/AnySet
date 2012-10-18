//
//  SongDetailViewController.h
//  AnySet
//
//  Created by Héctor Ramos on 10/17/12.
//
//

#import <UIKit/UIKit.h>

@interface SongDetailViewController : UIViewController <AVAudioPlayerDelegate>
@property (nonatomic, strong) IBOutlet UILabel *trackNameLabel;
@end
