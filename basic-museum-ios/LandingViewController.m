//
//  ViewController.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//


#import "LandingViewController.h"


@interface LandingViewController () <ESTBeaconManagerDelegate>

//Responsible for finding and tracking beacons in range
@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;

//Keeps track of beacon currently being displayed
@property (nonatomic, strong) NSNumber          *activeMinor;

//Contains all information regarding beacons in range and their content
@property (nonatomic, strong) NSMutableArray    *contentBeaconArray;

//Contains all information from the loaded JSON
@property (nonatomic, strong) NSMutableArray    *beaconContent;

//Audio player for playing mp3 files at exhibits
@property (nonatomic, strong) AVAudioPlayer     *audioPlayer;

//Keeps track of whether or not an exhibit's content is currently being displayed
@property (nonatomic) BOOL                      hasLanded;

//Allows the orientation to rotate if YES
@property (nonatomic) BOOL                      shouldRotate;

@end


/* LandingViewController
 * Currently the one and only view controller, this takes care of all beacon management
 * and content displaying.
 * @TODO Implement additional view controllers for customer, tours, modes, etc.
 */
@implementation LandingViewController

/* viewDidLoad
 * On starting up, start beacon managing and ranging
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Turn rotation off and affirm we have not hit the landing screen yet
    self.shouldRotate = NO;
    self.hasLanded = false;
    
    self.webView.delegate = self;
    
    // Setup beacon manager as this controller
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // Create a region to search for beacons
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"RegionIdentifier"];
    @try {
        [self.beaconManager startMonitoringForRegion:self.beaconRegion];
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
}

/* loadBeaconData
 * Retrieves JSON file from a source (currently local Lufthouse.JSON) and reads
 * the file into LufthouseCustomer and LufthouseTour objects.
 */
-(void)loadBeaconData
{
    // Create filepath to the local JSON
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Lufthouse" ofType:@"JSON"];
    // Begin reading JSON
    NSData *beaconJSON = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:beaconJSON options:0 error:&error];

    // If JSON didn't blow up
    if([json isKindOfClass:[NSDictionary class]]){
        // Create a dictionary out of the JSON
        NSDictionary *results = json;
        // All key values for the three layers to the JSON
        NSArray *outterKeys = [results allKeys];
        NSArray *innerKeys, *valueKeys;
        
        /* Arrays to hold data before storing it into tours, customers, and ulimately
         * self.beaconContent
         */
        NSMutableArray *beaconIDs, *beaconValues, *beaconAudio, *beaconTypes, *tours, *customers;
        
        //Temporary customer and tour
        LufthouseCustomer *tempCustomer;
        LufthouseTour *tempTour;
        
        //Clear customers for all incoming new customers
        customers = [NSMutableArray array];
        
        //For each customer in the JSON
        for (NSString *outterKey in outterKeys) {
            //Get the tour names
            innerKeys = [[results objectForKey:outterKey] allKeys];
            //Prep tours for storing new tours
            tours = [NSMutableArray array];
            
            //For each tour in a customer
            for (NSString *innerKey in innerKeys) {
                //Get all beacons in the tour
                valueKeys = [[[results objectForKey:outterKey] objectForKey:innerKey] allKeys];
                
                //Prep for data
                beaconIDs = [NSMutableArray array];
                beaconValues = [NSMutableArray array];
                beaconTypes = [NSMutableArray array];
                beaconAudio = [NSMutableArray array];
                
                //For each beacon in a tour
                for (NSString *valueKey in valueKeys) {
                    //Add the id, content, content type, and audio
                    [beaconIDs addObject:valueKey];
                    [beaconValues addObject:[[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex: 0]];
                    [beaconTypes addObject:[[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex:1]];
                    [beaconAudio addObject: [[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey] objectAtIndex: 2]];
                }
                //Create a tour out of all the data just loaded
                tempTour = [[LufthouseTour alloc] initTourWithName:innerKey beaconIDArray:beaconIDs beaconContentArray:beaconValues beaconContentTypeArray:beaconTypes beaconAudioArray:beaconAudio];
                //Add tempTour to the list of tours the customer has
                [tours addObject:tempTour];
            }
            //Create a customer using the parsed tours and a name
            tempCustomer = [[LufthouseCustomer alloc] initWithCustomerName:outterKey customerTours:tours];
            //Add the customer to a list of all customers
            [customers addObject:tempCustomer];
        }
        
        //Assign the beacon content for access elsewhere
        self.beaconContent = customers;
    }
}

/* beaconManager
 *
 */
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
                        NSLog(@"Beacon matched! %@", [currentBeacon minor] );
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
        if(([checkBeacon proximity] == CLProximityImmediate) && ![checkBeacon.minor isEqual:self.activeMinor] && [checkBeacon.minor isEqual:[[[beaconArray objectAtIndex:0] objectAtIndex:i] minor]]) {
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
    static NSString *youTubeVideoHTML = @"<html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = 'http://www.youtube.com/player_api'; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@' }); } </script> </body> </html>";
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, self.webView.frame.size.width, self.webView.frame.size.height, videoId];
    
    [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.waiting startAnimating];
    self.waiting.hidden = FALSE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.waiting stopAnimating];
    self.waiting.hidden = TRUE;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    ContentViewController *nextView = [segue destinationViewController];
//    
//    self.currentView = [nextView getContentViewView];
//    [nextView setDisplayURLString:self.sendableURLString];
//}


@end