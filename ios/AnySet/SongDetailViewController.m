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
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playNextSong) name:@"noLongerEmpty" object:self.playlist];
    [self playNextSong];
}

- (void)playNextSong {
    if (self.currentRequest) {
        self.currentRequest[@"done"] = @YES;
        [self.currentRequest saveEventually];
        self.currentRequest = nil;
    }
    
    if (!self.playlist.objects.count) {
        //        [self.playlist loadObjects];

        dispatch_after(500, dispatch_get_main_queue(), ^{ [self playNextSong]; });
        return;
    }

    self.currentRequest = self.playlist.objects[0];
    PFQuery *songQuery = [PFQuery queryWithClassName:@"Song"];
    [songQuery whereKey:@"name" containsString:self.currentRequest[@"name"]];
    
    [self.playlist loadObjects];
    
    [songQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self playNextSong]; });
            return;
        }
        PFFile *file = [object objectForKey:@"data"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self playFileWithData:data];
            }
        }];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self playNextSong];
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
