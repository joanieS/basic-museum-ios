//
//  ViewController.h
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/5/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSJSONSerialization.h>
#import "ESTBeacon.h"
#import "LufthouseCustomer.h"
#import "LufthouseTour.h"


@interface LandingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *landingView;
@property (weak, nonatomic) IBOutlet UIImageView *lufhouseLogo;
@property (weak, nonatomic) IBOutlet UILabel *lufthouseTitle;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end
