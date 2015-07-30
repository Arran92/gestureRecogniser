//
//  Matrix.h
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Matrix : NSObject

@property (nonatomic,assign) uint rows;
@property (nonatomic,assign) uint cols;
@property (nonatomic,assign) float** data;






- (void)printVector:(float*)vec withSize:(uint)size;
- (void)printMatrix;
- (void)emptyMatrix;
- (void)copy:(float*)source Into:(float*)target andSize:(uint)size;
- (Matrix*)initMatrixWithRows:(uint)rows andCols:(uint)cols;

+ (Matrix*)zeroVec3;

@end
