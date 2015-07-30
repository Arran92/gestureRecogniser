//
//  Score.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

@property (nonatomic,retain) NSString *gid;
@property (nonatomic,assign) int idnr;
@property float distance;
@property float score;

- (NSComparisonResult)compare:(Score*)otherScore;
@end
