//
//  LufthouseCustomer.h
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/17/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LufthouseTour.h"

@interface LufthouseCustomer : NSObject

@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSMutableArray *tours;

/* Create the customer with tours */
-(LufthouseCustomer *) initWithCustomerName: (NSString *) customerName customerTours: (NSMutableArray *) tours;

/* Get the tours or a specific tour */
-(NSMutableArray *) getTours;
-(LufthouseTour *) getTourAtIndex: (NSInteger) index;

/* Look for a tour and return its index */
-(NSInteger) findTourName: (NSString *) targetName;

@end
