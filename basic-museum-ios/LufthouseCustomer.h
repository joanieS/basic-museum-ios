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

-(LufthouseCustomer *) initWithCustomerName: (NSString *) customerName customerTours: (NSMutableArray *) tours;

-(void) addTour: (LufthouseTour *) tour;

-(NSInteger) findTourName: (NSString *) targetName;

-(NSMutableArray *) getTours;

-(LufthouseTour *) getTourAtIndex: (NSInteger) index;

@end
