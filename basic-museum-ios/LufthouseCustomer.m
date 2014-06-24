//
//  LufthouseCustomer.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/17/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "LufthouseCustomer.h"

/* LufthouseCustomer
 * Object to hold an array of tours that belong to one unique customer. Has a name
 * and said array of tours, and functions to find a tour name, return the tours, 
 * and return a tour at an index.
 * The customer's bundle o' tours shouldn't ever change, so no setter methods besides
 * initialization exist.
 */
@implementation LufthouseCustomer

/* initWithCustomerName
 * Takes a name and an array of tours to create a customer
 */
-(LufthouseCustomer *) initWithCustomerName: (NSString *) customerName customerTours: (NSMutableArray *) tours
{
    //If the tours aren't actually tours, shut this sucker down
    if ([[tours firstObject] isKindOfClass:[LufthouseTour class]]) {
        self.customerName = customerName;
        self.tours = tours;
        return self;
    }
    else
        return nil;

}

/* getTours */
-(NSMutableArray *) getTours
{
    return self.tours;
}

/* getTourAtIndex */
-(LufthouseTour *) getTourAtIndex: (NSInteger) index
{
    return self.tours[index];
}

/* findTourName
 * Loops through tours to find a specified tour name. Returns the index of this tour
 */
-(NSInteger) findTourName: (NSString *) targetName
{
    LufthouseTour * checkTour;
    // For each tour the customer has, check the tour name
    for (NSInteger i = 0; i < [self.tours count]; i++) {
        checkTour = [self.tours objectAtIndex:i];
        if ([[checkTour getTourName] isEqualToString:targetName]) {
            return i;
        }
    }
    
    // If not found, return an impossible index
    return -1;
}

@end
