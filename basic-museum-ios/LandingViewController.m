//
//  ViewController.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "LandingViewController.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"
#import "LandingViewController.h"

@interface LandingViewController () <ESTBeaconManagerDelegate>

//Responsible for finding and tracking beacons in range
@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;

//Keeps track of beacon currently being displayed
@property (nonatomic, strong) NSNumber          *activeMinor;

//Contains all information regarding beacons in range and their content
@property NSMutableArray * contentBeaconArray;

//Contains all information from the loaded JSON
@property NSMutableArray * beaconContent;

//Audio player for playing mp3 files at exhibits
@property AVAudioPlayer *audioPlayer;

//Keeps track of whether or not an exhibit's content is currently being displayed
@property BOOL hasLanded;
@property BOOL shouldRotate;

@end



@implementation LandingViewController


/* loadBeaconData
 * Retrieves JSON file from a source (currently local Lufthouse.JSON) and reads
 * the file into LufthouseCustomer and LufthouseTour objects.
 */

-(void)loadBeaconData
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Lufthouse" ofType:@"JSON"];
    NSData *beaconJSON = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:beaconJSON options:0 error:&error];

    if([json isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *results = json;
        NSArray *outterKeys = [results allKeys];
        NSArray *innerKeys, *valueKeys;
        
        NSMutableArray *beaconIDs, *beaconValues, *beaconAudio, *beaconTypes, *tours, *customers;
        
        LufthouseCustomer *tempCustomer;
        LufthouseTour *tempTour;
        
        customers = [NSMutableArray array];
        for (NSString *outterKey in outterKeys) {
            innerKeys = [[results objectForKey:outterKey] allKeys];
            tours = [NSMutableArray array];
            for (NSString *innerKey in innerKeys) {
                valueKeys = [[[results objectForKey:outterKey] objectForKey:innerKey] allKeys];
                beaconIDs = [NSMutableArray array];
                beaconValues = [NSMutableArray array];
                beaconTypes = [NSMutableArray array];
                beaconAudio = [NSMutableArray array];
                for (NSString *valueKey in valueKeys) {
                    [beaconIDs addObject:valueKey];
                    [beaconValues addObject:[[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex: 0]];
                    [beaconTypes addObject:[[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex:1]];
                    [beaconAudio addObject: [[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex: 2]];
                    
                }
                tempTour = [[LufthouseTour alloc] initTourWithName:innerKey beaconIDArray:beaconIDs beaconContentArray:beaconValues beaconContentTypeArray:beaconTypes beaconAudioArray:beaconAudio];
                [tours addObject:tempTour];
            }
            tempCustomer = [[LufthouseCustomer alloc] initWithCustomerName:outterKey customerTours:tours];
            [customers addObject:tempCustomer];
        }
        
        self.beaconContent = customers;
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldRotate = NO;
    self.hasLanded = false;
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                         identifier:@"RegionIdentifier"];
    @try {
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
    {
        if ([self.beaconContent count] == 0) {
            [self loadBeaconData];
            NSLog(@"Beacon content loaded");
        }

        ESTBeacon *currentBeacon;
        NSString *stringifiedMinor;
        NSMutableArray *beaconAssignment = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
        NSInteger beaconIndex = -1;
        LufthouseTour *currentTour;
        
        for(int i = 0; i < [beacons count]; i++){
            currentBeacon = [beacons objectAtIndex:i];
            stringifiedMinor = [NSString stringWithFormat:@"%@", [currentBeacon minor]];
            for (LufthouseCustomer *customer in self.beaconContent) {
                for (NSInteger tourIndex = 0; tourIndex < [[customer getTours] count]; tourIndex++) {
                    currentTour = [customer getTourAtIndex:tourIndex];
                    beaconIndex = [currentTour findIndexOfID:stringifiedMinor];
                    if (beaconIndex != -1) {
                        [beaconAssignment[0] addObject:currentBeacon];
                        [beaconAssignment[1] addObject:[currentTour getBeaconContentAtIndex:beaconIndex]];
                        [beaconAssignment[2] addObject:[currentTour getBeaconContentTypeAtIndex:beaconIndex]];
                        [beaconAssignment[3] addObject:[currentTour getBeaconAudioAtIndex:beaconIndex]];
                        NSLog(@"%s", "Beacon matched!");
                    }
                }
            }
        }
        
        if ([beaconAssignment[0] count] > 0) {
            self.contentBeaconArray = beaconAssignment;
        }
        
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:[beacons firstObject] waitUntilDone:YES];
}

-(void)doVolumeFade: (NSString *)nextSong
{
    if (self.audioPlayer.volume > 0.1 && [self.audioPlayer isPlaying]) {
        self.audioPlayer.volume = self.audioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade:) withObject:nextSong afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = 1.0;
        
        NSError *error;
        if (nextSong != nil) {
            self.audioPlayer = nil;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[[NSData alloc] initWithContentsOfFile:nextSong] error:&error];
            self.audioPlayer.numberOfLoops = 0;
//            self.audioPlayer.delegate = self;
            
            if (self.audioPlayer == nil)
                NSLog(@"%@", [error description]);
            else
                [self.audioPlayer play];
        }
    }
}

- (void)updateUI:(ESTBeacon *)checkBeacon
{

    NSMutableArray *beaconArray = self.contentBeaconArray;
    NSURL *beaconURL;
    NSString *url;
    NSURLRequest *beaconRequest = nil;
    for(int i = 0; i < [beaconArray[0] count]; i++) {
        if(([checkBeacon proximity] == CLProximityNear  || [checkBeacon proximity] == CLProximityImmediate) && ![checkBeacon.minor isEqual:self.activeMinor] && [checkBeacon.minor isEqual:[[[beaconArray objectAtIndex:0] objectAtIndex:i] minor]]) {
            self.activeMinor = [[[beaconArray objectAtIndex:0] objectAtIndex:i] minor];
            if(!([beaconArray[2][i] rangeOfString:@"image"].location == NSNotFound)) {
                beaconURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], beaconArray[1][i]]];
                beaconRequest = [NSURLRequest requestWithURL:beaconURL];
                [self.webView loadRequest:beaconRequest];
            }
            else if(!([beaconArray[2][i] rangeOfString:@"web-video"].location == NSNotFound)) {
                [self playVideoWithId:beaconArray[1][i]];
            }
            else if(!([beaconArray[2][i] rangeOfString:@"local-video"].location == NSNotFound)) {
                beaconURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], beaconArray[1][i]]];
                beaconRequest = [NSURLRequest requestWithURL:beaconURL];
                [self.webView loadRequest:beaconRequest];
            }
            else if(!([beaconArray[2][i] rangeOfString:@"web"].location == NSNotFound)) {
                beaconURL = [NSURL URLWithString:beaconArray[1][i]];
                beaconRequest = [NSURLRequest requestWithURL:beaconURL];
                [self.webView loadRequest:beaconRequest];
                NSLog(@"%@", beaconRequest);
            }
            
            if ([[[beaconArray objectAtIndex:2] objectAtIndex:i] isEqualToString:@"nil"]) {
                url = nil;
            }
            else {
                url = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], [[beaconArray objectAtIndex:2] objectAtIndex:i]];
            }
            
            [self doVolumeFade:url];
            
            self.hasLanded = false;
            self.shouldRotate = YES;
        }
    }
    if (checkBeacon == nil && self.hasLanded == false) {
        beaconURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"landingImage.png"]];
        NSURLRequest *beaconRequest = [NSURLRequest requestWithURL:beaconURL];
        [self.webView loadRequest:beaconRequest];
        [self doVolumeFade:nil];
        self.hasLanded = true;
        self.activeMinor = 0000;
        self.shouldRotate = NO;
    }
}

- (BOOL)shouldAutorotate {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&  self.shouldRotate == NO) {
        return YES;
    }
    else
        return self.shouldRotate;
}

- (void)playVideoWithId:(NSString *)videoId {
    static NSString *youTubeVideoHTML = @"<html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = 'http://www.youtube.com/player_api'; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, self.webView.frame.size.width, self.webView.frame.size.height, videoId];
    
    [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    ContentViewController *nextView = [segue destinationViewController];
//    
//    self.currentView = [nextView getContentViewView];
//    [nextView setDisplayURLString:self.sendableURLString];
//}


@end