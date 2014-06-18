//
//  LufthouseCustomer.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/17/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "LufthouseCustomer.h"

@implementation LufthouseCustomer

-(LufthouseCustomer *) initWithCustomerName: (NSString *) customerName customerTours: (NSMutableArray *) tours
{
    self.customerName = customerName;
    self.tours = tours;
    
    return self;
}

-(void) addTour: (LufthouseTour *) tour
{
    [self.tours addObject:tour];
}

-(NSInteger) findTourName: (NSString *) targetName
{
    LufthouseTour * checkTour;
    for (NSInteger i = 0; i < [self.tours count]; i++) {
        checkTour = [self.tours objectAtIndex:i];
        if ([[checkTour getTourName] isEqualToString:targetName]) {
            return i;
        }
    }
    
    return -1;
}

-(NSMutableArray *) getTours
{
    return self.tours;
}

-(LufthouseTour *) getTourAtIndex: (NSInteger) index
{
    return self.tours[index];
}

@end
