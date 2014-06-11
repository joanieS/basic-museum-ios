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




//NSString * const REGION_IDENTIFER           = @"regionid";
//NSNumber * targetBeaconMajorValues[3];
//NSNumber * targetBeaconMinorValues[3];
//NSArray * const beaconContent[3] = [NSArray arrayWithObjects:{@"The Boxer Revolution", @"Duke Ellington", @"Steve Job"}, {[UIColor redColor], [UIColor blueColor], [UIColor greenColor]}, nil];


@interface ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;

@property (nonatomic) CAShapeLayer *indicatorBackgroundLayer;

@property NSMutableArray * contentBeaconArray;
//@property ESTBeacon * beaconBoxerRevolution;
//@property ESTBeacon * beaconDukeEllington;
//@property ESTBeacon * beaconSteveJobs;
@property ESTBeacon * activeBeacon;

@property NSArray * targetBeaconMajorValue;
@property NSArray * targetBeaconMinorValue;
@property NSArray * beaconContent;


@end

@implementation ViewController

- (id)initWithBeacon:(ESTBeacon *)beacon
{
    self = [super init];
    if (self)
    {
        self.beacon = beacon;
    }
    return self;
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
        if([self.beaconContent count] == 0) {
            self.beaconContent = [NSArray arrayWithObjects:[NSArray arrayWithObjects: @"The Boxer Revolution", @"Duke Ellington", @"Steve Job", nil], [NSArray arrayWithObjects: [UIColor redColor], [UIColor blueColor], [UIColor greenColor], nil], nil];
        }
        if([self.targetBeaconMinorValue count] == 0) {
            self.targetBeaconMajorValue =  [NSArray arrayWithObjects: [NSNumber numberWithLong:57770],[NSNumber numberWithLong:14412], [NSNumber numberWithLong:1010], nil];
            self.targetBeaconMinorValue = [NSArray arrayWithObjects:[NSNumber numberWithLong:47919], [NSNumber numberWithLong:39720], [NSNumber numberWithLong:62689], nil];
            self.contentBeaconArray = [NSMutableArray arrayWithCapacity:self.targetBeaconMajorValue.count];
        }
    
    ESTBeacon *currentBeacon;
    
    for(int i = 0; i < [beacons count]; i++){
        currentBeacon = [beacons objectAtIndex:i];
        for(int j = 0; j < [beacons count]; j++){
            if ([currentBeacon.major isEqual:self.targetBeaconMajorValue[i]] && [currentBeacon.minor isEqual:self.targetBeaconMinorValue[i]]){
//                [self.contentBeaconArray :currentBeacon];
                self.contentBeaconArray[i] = currentBeacon;
                NSLog(@"%s", "Beacon matched!");
            }
        }
    }
        
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:self.contentBeaconArray waitUntilDone:YES];
}

- (void)updateUI:(NSMutableArray *)beaconArray
{
//    self.beaconUuidLabel.text = [beacon.proximityUUID UUIDString];
//    self.beaconVersionLabel.text = [NSString stringWithFormat:@"%@: %d  %@: %d",
//                                    @"Major",
//                                    BEACON_MAJOR_VERSION,
//                                    @"Minor",
//                                    BEACON_MINOR_VERSION];
//    
    ESTBeacon * checkBeacon;
    
    for(int i = 0; i < [beaconArray count]; i++) {
        checkBeacon = beaconArray[i];
        if([beaconArray[i] proximity] == CLProximityNear) {
            NSLog(@"%@", self.beaconContent[0][i]);
            self.contentTitle.text = self.beaconContent[0][i];
            self.indicatorBackgroundLayer.strokeColor = [self.beaconContent[1][i] CGColor];
        }
    }
    
    
}

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