//
//  ContentViewController.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/13/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@property (nonatomic)  NSString *displayURLString;

@end

@implementation ContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDisplayURLString:(NSString *)displayURLString
{
    self.displayURLString = displayURLString;
}

-(UIView *)getContentViewView
{
    return self.ContentView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
