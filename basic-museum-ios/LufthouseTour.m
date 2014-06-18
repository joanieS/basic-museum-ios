//
//  LufthouseTour.m
//  basic-museum-ios
//
//  Created by Adam Gleichsner on 6/17/14.
//  Copyright (c) 2014 Lufthouse. All rights reserved.
//

#import "LufthouseTour.h"

@implementation LufthouseTour

-(LufthouseTour *)initTourWithName: (NSString *) tourName beaconIDArray: (NSMutableArray *) beaconIDs beaconContentArray: (NSMutableArray *) beaconContent
{
    self.tourName = tourName;
    self.beaconIDs = beaconIDs;
    self.beaconContent = beaconContent;
    
    return self;
}

-(NSString *)getTourName
{
    return self.tourName;
}

-(NSString *)getBeaconIDAtIndex: (NSInteger) index
{
    return [self.beaconIDs objectAtIndex:index];
}

-(NSString *)getBeaconContentAtIndex: (NSInteger) index
{
    return [self.beaconContent objectAtIndex:index];
}

-(void)addBeaconID: (NSString *) newID addBeaconContent:(NSString *) newContent
{
    [self.beaconIDs addObject:newID];
    [self.beaconContent addObject:newContent];
}

-(NSInteger)findIndexOfID: (NSString *) targetID
{
    NSString *checkID;
    for(NSInteger i = 0; i < [self.beaconIDs count]; i++){
        checkID = [self.beaconIDs objectAtIndex:i];
        if ([checkID isEqualToString:targetID]) {
            return i;
        }
    }
    
    return -1;
}

-(NSInteger)findIndexOfContent: (NSString *) targetContent
{
    NSString *checkContent;
    for (NSInteger i = 0; i < [self.beaconContent count]; i++) {
        checkContent = [self.beaconContent objectAtIndex:i];
        if ([checkContent isEqualToString:targetContent]) {
            return i;
        }
    }
    
    return -1;
}



@end
