//
//  SongDetailViewController.m
//  AnySet
//
//  Created by Héctor Ramos on 10/17/12.
//
//

#import "SongDetailViewController.h"

@interface SongDetailViewController ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation SongDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Loaded detail");
    
    PFQuery *songQuery = [PFQuery queryWithClassName:@"Song"];
    [songQuery whereKey:@"name" hasPrefix:@"ghost"];
    [songQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            PFFile *file = [object objectForKey:@"data"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    [self playFileWithData:data];
                }
            } progressBlock:^(int percentDone) {
            }];
        }
    }];
    
	// Do any additional setup after loading the view.
    /*
    NSData *appKeyData = [NSData dataWithBytesNoCopy:g_appkey
                                              length:g_appkey_size
                                        freeWhenDone:NO];
    SPSession *session =
        [SPSession initializeSharedSessionWithApplicationKey:appKeyData
                                                   userAgent:
                                               loadingPolicy:<#(SPAsyncLoadingPolicy)#> error:<#(NSError *__autoreleasing *)#>]
    [SPLoginViewController loginControllerForSession:session];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
//    [self playNextSong];
}

#pragma mark - ()

- (void)playFileAtURL:(NSURL *)url {	
    NSError *error;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
	self.audioPlayer.numberOfLoops = 1;
	
	if (self.audioPlayer == nil)
		NSLog(@"%@", [error description]);
	else
		[self.audioPlayer play];
    
}

- (void)playFileWithData:(NSData *)data {
    NSError *error;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.audioPlayer.delegate = self;
	self.audioPlayer.numberOfLoops = 1;
	
	if (self.audioPlayer == nil)
		NSLog(@"%@", [error description]);
	else
		[self.audioPlayer play];
}

@end
