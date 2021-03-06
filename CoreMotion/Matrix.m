//
//  Matrix.m
//  CoreMotion
//
//  Created by Arran Purewal on 22/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "Matrix.h"

static int MATRIX_COUNT = 0;

@implementation Matrix

- (void)printVector:(float *)vec withSize:(uint)size {
    

    
    NSMutableString *out = [[NSMutableString alloc]initWithString:@""];
    for(int i = 0; i < size; i++) {
        [out appendFormat:@"\t %f",vec[i]];
    }
    NSLog(@"%@",out);
}

- (void)printMatrix {
    for(int i = 0; i < self.rows; i++) {
        [self printVector:self.data[i] withSize:self.cols];
    }
}

- (void)emptyMatrix {
    
    for(int j = 0 ; j < self.rows; j++) {
        bzero(self.data[j], sizeof(float[self.cols]));
    }
}

- (id)initMatrixWithRows:(uint)rows andCols:(uint)cols {
    
    if(self = [super init]) {
       
       
        MATRIX_COUNT++;
        if(MATRIX_COUNT % 10000 == 0) {
            NSLog(@"MATRIX created COUNT: %d",MATRIX_COUNT);
        }
        self.rows = rows;
        self.cols = cols;
        self.data = (float**)malloc(sizeof(float*)*self.rows);
        for(int i = 0; i < self.rows; i++) {
            self.data[i] = (float*) malloc(sizeof(float)*self.cols);

            
        }
        [self emptyMatrix];
    }
    return self;
}

+ (id)zeroVec3 {
    Matrix *zero = [[Matrix alloc]initMatrixWithRows:(uint) 1 andCols:(uint) 3];
    return zero;
}

- (void)copy:(float *)source Into:(float *)target andSize:(uint)size {
    for(int i = 0; i < size; i++) {
        target[i] = source[i];
    }
}



@end
