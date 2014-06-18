//
//  ViewController.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "LandingViewController.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"
#import "LandingViewController.h"
#import "ContentViewController.h"


@interface LandingViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;
@property (nonatomic, strong) NSNumber          *activeMinor;

@property (nonatomic) CAShapeLayer *indicatorBackgroundLayer;

@property NSMutableArray * contentBeaconArray;
@property ESTBeacon * activeBeacon;

@property NSMutableArray * beaconContent;
@property NSString *sendableURLString;


@end

@implementation LandingViewController

- (id)initWithBeacon:(ESTBeacon *)beacon
{
    self = [super init];
    if (self)
    {
        self.beacon = beacon;
    }
    return self;
}

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
        
        NSMutableArray *beaconIDs, *beaconValues, *tours, *customers;
        
        LufthouseCustomer *tempCustomer;
        LufthouseTour *tempTour;
        
        customers = [NSMutableArray array];
        for (NSString *outterKey in outterKeys) {
//            [contentFromJSON addObject:[[results objectForKey:outterKey] allValues]];
            innerKeys = [[results objectForKey:outterKey] allKeys];
            tours = [NSMutableArray array];
            for (NSString *innerKey in innerKeys) {
                valueKeys = [[[results objectForKey:outterKey] objectForKey:innerKey] allKeys];
                beaconIDs = [NSMutableArray array];
                beaconValues = [NSMutableArray array];
                for (NSString *valueKey in valueKeys) {
                    [beaconIDs addObject:valueKey];
                    [beaconValues addObject:[[[results objectForKey:outterKey] objectForKey:innerKey] objectForKey:valueKey]];
                }
                tempTour = [[LufthouseTour alloc] initTourWithName:innerKey beaconIDArray:beaconIDs beaconContentArray:beaconValues];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, self.indicatorBackgroundLayer.bounds);
    self.indicatorBackgroundLayer.path = path;
    
}



- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
    {
        if ([self.beaconContent count] == 0) {
            [self loadBeaconData];
            NSLog(@"Beacon content loaded");
        }

        ESTBeacon *currentBeacon;
        NSString *stringifiedMinor;
        NSMutableArray *beaconAssignment = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], nil];
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

- (void)updateUI:(ESTBeacon *)beacon
{
    ESTBeacon * checkBeacon;
    NSMutableArray *beaconArray = self.contentBeaconArray;
    NSURL *beaconURL;
    for(int i = 0; i < [beaconArray[0] count]; i++) {
        checkBeacon = beacon;
        self.sendableURLString = beaconArray[1][i];
        if(([checkBeacon proximity] == CLProximityNear  || [checkBeacon proximity] == CLProximityImmediate) && ![checkBeacon.minor isEqual:self.activeMinor] && [checkBeacon.minor isEqual:[[[beaconArray objectAtIndex:0] objectAtIndex:i] minor]]) {
            self.activeMinor = [[[beaconArray objectAtIndex:0] objectAtIndex:i] minor];
            beaconURL = [NSURL URLWithString:beaconArray[1][i]];
            NSURLRequest *beaconRequest = [NSURLRequest requestWithURL:beaconURL];
            [self.webView loadRequest:beaconRequest];
        
        }
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    ContentViewController *nextView = [segue destinationViewController];
//    
//    self.currentView = [nextView getContentViewView];
//    [nextView setDisplayURLString:self.sendableURLString];
//}

//- (IBAction)changeActiveBeacon
//{
//    
//    if (self.activeBeacon == self.beaconBoxerRevolution) {
//        self.activeBeacon = self.beaconDukeEllington;
//    }
//    else if (self.activeBeacon == self.beaconDukeEllington) {
//        self.activeBeacon = self.beaconSteveJobs;
//    }
//    else if (self.activeBeacon == self.beaconSteveJobs) {
//        self.activeBeacon = self.beaconBoxerRevolution;
//    }
//    else {
//        self.activeBeacon = self.beaconBoxerRevolution;
//    }
//}


@end