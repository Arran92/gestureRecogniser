//
//  Score.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "Score.h"

@implementation Score

- (id)init {
    
    if(self = [super init]) {
        self.gid = nil;
        self.idnr = 0;
        self.distance = MAXFLOAT;
        self.score = 0.0;
    }
    return self;
}

- (NSComparisonResult)compare:(Score*)otherScore {
    if(self.score > otherScore.score)
        return NSOrderedAscending;
    else if (self.score < otherScore.score)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@end
