//
//  ViewController.h
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"


@interface ViewController : UIViewController

//@property (nonatomic) IBOutlet UILabel *beaconUuidLabel;
//@property (nonatomic) IBOutlet UILabel *beaconVersionLabel;
//@property (nonatomic) IBOutlet UILabel *beaconStatsLabel;
@property (nonatomic) IBOutlet UIView *indicatorView;
@property (nonatomic) IBOutlet UILabel *indicatorLabel;
@property (nonatomic) IBOutlet UILabel *contentTitle;
@property (nonatomic) IBOutlet UIImage *lufthouseLogo;
//-(IBAction)changeActiveBeacon;
- (id)initWithBeacon:(ESTBeacon *)beacon;

@end
