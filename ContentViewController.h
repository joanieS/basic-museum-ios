//
//  ContentViewController.h
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/13/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"

@interface ContentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

-(void)setDisplayURLString:(NSString *)displayURLString;

-(UIView *)getContentViewView;

@end
