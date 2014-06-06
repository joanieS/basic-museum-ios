//
//  ViewController.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "ViewController.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"
#import "ViewController.h"

NSString * const REGION_IDENTIFER           = @"regionid";
CLBeaconMajorValue BEACON_MAJOR_VERSION     = 8727;
CLBeaconMajorValue BEACON_MINOR_VERSION     = 42728;


@interface ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic) CAShapeLayer *indicatorBackgroundLayer;

@property ESTBeacon * beaconBoxerRevolution;
@property ESTBeacon * beaconDukeEllington;
@property ESTBeacon * beaconSteveJobs;
@property ESTBeacon * activeBeacon;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                       major:BEACON_MAJOR_VERSION
                                        minor:BEACON_MINOR_VERSION                                                                  identifier:REGION_IDENTIFER];
    
    [self.beaconManager startRangingBeaconsInRegion:region];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.indicatorView.clipsToBounds = YES;
    
    self.indicatorBackgroundLayer = [CAShapeLayer layer];
    self.indicatorBackgroundLayer.bounds = CGRectMake(self.indicatorView.bounds.origin.x,
                                                      self.indicatorView.bounds.origin.y,
                                                      self.indicatorView.bounds.size.width - 10,
                                                      self.indicatorView.bounds.size.height - 10);
    
    self.indicatorBackgroundLayer.position = CGPointMake(CGRectGetMidX(self.indicatorView.bounds), CGRectGetMidY(self.indicatorView.bounds));
    self.indicatorBackgroundLayer.fillColor = [[UIColor whiteColor] CGColor];
    self.indicatorBackgroundLayer.strokeColor = [[UIColor blackColor] CGColor];
    self.indicatorBackgroundLayer.lineWidth = 8.0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, self.indicatorBackgroundLayer.bounds);
    self.indicatorBackgroundLayer.path = path;
    
    [self.indicatorView.layer insertSublayer:self.indicatorBackgroundLayer atIndex:0];
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    if ([beacons count] > 0) {
//        ESTBeacon *closestBeacon = [beacons firstObject];
        ESTBeacon *currentBeacon = [beacons firstObject];
        for (int i = 0; i < [beacons count]; i++) {
            ESTBeacon *currentBeacon = [beacons objectAtIndex:i];
            if (currentBeacon.proximityUUID ==  [[NSUUID alloc] initWithUUIDString:@"86E4BDEA-C6FF-442C-95CB-E6E557A23CF2"]) {
                self.beaconBoxerRevolution = currentBeacon;
            }
            else if (currentBeacon.proximityUUID ==  [[NSUUID alloc] initWithUUIDString:@"A50598FD-5CE0-4359-B47B-1D0C313B3651"]) {
                self.beaconDukeEllington = currentBeacon;
            }
            else if (currentBeacon.proximityUUID ==  [[NSUUID alloc] initWithUUIDString:@"E9E24881-3250-4106-8522-28079D6A51CD"]) {
                self.beaconSteveJobs = currentBeacon;
            }
        }
        
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:currentBeacon waitUntilDone:YES];
    }
    
    else if ([beacons count] == 0) {
        self.beaconBoxerRevolution = [ESTBeacon init];
        self.beaconBoxerRevolution.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"86E4BDEA-C6FF-442C-95CB-E6E557A23CF2"];
        self.beaconDukeEllington = [ESTBeacon init];
        self.beaconDukeEllington.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"A50598FD-5CE0-4359-B47B-1D0C313B3651"];
        self.beaconSteveJobs = [ESTBeacon init];
        self.beaconSteveJobs.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"E9E24881-3250-4106-8522-28079D6A51CD"];
        
        ESTBeacon *currentBeacon = self.beaconBoxerRevolution;
        
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:currentBeacon waitUntilDone:YES];
    }
}

- (void)updateUI:(ESTBeacon *)beacon
{
//    self.beaconUuidLabel.text = [beacon.proximityUUID UUIDString];
//    self.beaconVersionLabel.text = [NSString stringWithFormat:@"%@: %d  %@: %d",
//                                    @"Major",
//                                    BEACON_MAJOR_VERSION,
//                                    @"Minor",
//                                    BEACON_MINOR_VERSION];
//    
    if(self.beaconBoxerRevolution.proximity == CLProximityImmediate){
        //Insert content for beacon; Boxer Revolution
            {
                self.indicatorLabel.text = @"The Boxer Revolution";
                self.indicatorBackgroundLayer.strokeColor = [[UIColor redColor] CGColor];
            }
    }
    
    else if(self.beaconDukeEllington.proximity == CLProximityImmediate){
        //Insert content for beacon; Duke Ellington
        {
            self.indicatorLabel.text = @"Duke Ellington";
            self.indicatorBackgroundLayer.strokeColor = [[UIColor blueColor] CGColor];
        }
    }
    
    else if(self.beaconSteveJobs.proximity == CLProximityImmediate){
        //Insert content for beacon; Steve Jobs
        {
            self.indicatorLabel.text = @"Steve Jobs";
            self.indicatorBackgroundLayer.strokeColor = [[UIColor greenColor] CGColor];
        }
    }
    
}

- (IBAction)changeActiveBeacon
{
    
    if (self.activeBeacon == self.beaconBoxerRevolution) {
        self.activeBeacon = self.beaconDukeEllington;
    }
    else if (self.activeBeacon == self.beaconDukeEllington) {
        self.activeBeacon = self.beaconSteveJobs;
    }
    else if (self.activeBeacon == self.beaconSteveJobs) {
        self.activeBeacon = self.beaconBoxerRevolution;
    }
    else {
        self.activeBeacon = self.beaconBoxerRevolution;
    }
}


@end