//
//  GestureDB.m
//  CoreMotion
//
//  Created by Arran Purewal on 24/07/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "GestureDB.h"


@implementation GestureDB

static GestureDB *sharedInstance = nil;

static sqlite3 *database = nil;
static sqlite3_stmt *deleteStmt = nil;
static sqlite3_stmt *addStmt = nil;

+ (id)sharedInstance {
    
    if(sharedInstance == nil) {
        sharedInstance = [[GestureDB alloc]init];
        NSLog(@" sharedInstance:creating gesture database");
    }
    return sharedInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    if(sharedInstance == nil) {
        sharedInstance = [super allocWithZone:zone];
    }
    return sharedInstance;
}

- (id)init {
    
    if(self = [super init]) {
        NSLog(@"creating database");
        self.filename = @"Gestures.sqlite";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.path = [documentsDirectory stringByAppendingPathComponent:self.filename];
        [self checkAndCreateDatabase];
        [self readGesturesFromDatabase];
    }
    return self;
}


- (void)saveToFile {
    
    NSLog(@"%@: saving file: %@ under path: %@",[self class],self.filename,self.path);
    
//    if(![self.gestures writeToFile:self.path atomically:YES]) {
//        NSLog(@"%@: ERROR could not save file: %@ at path %@",[self class],self.filename,self.path);
//    }
    
    //save the dictionary to file and then compare it to the gestures
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
   
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"dict.plist"];

    NSError *error;
    
    NSDictionary *new = [NSDictionary dictionaryWithDictionary:self.gestureDict];

    
    
 //   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:new
    //                                                   options:0
      //                                                   error:&error];
    
    
  //  BOOL success = [new writeToFile:filePath atomically:YES];
    
   BOOL success = [NSKeyedArchiver archiveRootObject:new toFile:filePath];
    
    if(success)
        NSLog(@"WRITING TO FILE");
    
    else
        NSLog(@"DID NOT SAVE");
  
    
}

//- (IBAction)saveUser:(id)sender{
//    NSString *name = [nameField stringValue];
//    NSString *weight = [weightField stringValue];
//    NSDate *date = [datePick dateValue];
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setValue:[nameField stringValue] forKey:@"name"];
//    [dict setValue:[weightField stringValue] forKey:@"weight"];
//    [dict setValue:date forKey:@"date"];
//    [dict writeToFile:name atomically:YES];
//}

#pragma adding gestures
- (BOOL)addGesture:(Gesture *)aGesture {
    
    
    if(self.gestures != nil) {
        NSLog(@"%@: adding gesture: %@",[self class],aGesture.gestureID);
        BOOL dbSuccess = [self addGesturetoDB:aGesture];
        if(dbSuccess)
            NSLog(@"DB SUCCESS");
        BOOL arraySuccess = [self addGestureToArray:aGesture];
        if(arraySuccess)
            NSLog(@"ARRAY SUCCESS");
        
        if(dbSuccess && arraySuccess) {
            NSLog(@"%@: gesture successfully added with id %d",[self class],aGesture.databaseID);
            return YES;
        }
        return NO;
    }
    else {
        return NO;
    }
}


- (BOOL)addGestureToArray:(Gesture *)aGesture {
    if(self.gestures != nil) {
        [self.gestures addObject:aGesture];
        
        NSMutableArray *arrayForNames = [self.gestureDict objectForKey:aGesture.gestureID];
        
        if([arrayForNames count] > 0) {
            [arrayForNames addObject:aGesture];
           
        }
        else {
            NSMutableArray *newNameArray = [[NSMutableArray alloc]initWithCapacity:5];
            [newNameArray addObject:aGesture];
            [self.gestureDict setValue:newNameArray forKey:aGesture.gestureID];
        }
        Matrix *printGestureTrace = [[Matrix alloc]init];
        printGestureTrace = aGesture.gestureTrace;
        
        NSLog(@"PRINTING GESTURE");
        
        [printGestureTrace printMatrix];
        
        return YES;
        
    }
    else {
        return NO;
    }
    return NO;
}




- (BOOL)addGesturetoDB:(Gesture *)gesture {
    

    
    if(addStmt == nil) {
        const char *sql = "INSERT INTO gestureTraces(traceData,gestureID,dateAdded Values (?,?,?)";
        if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK) {
       //     NSAssert1(0, @"error while creating add stmt '%s'", sqlite3_errmsg(database));
            NSLog(@"STOP");
        }
    }
    
    NSData *matrixData = [self getDataFromMatrix:gesture.gestureTrace];
    
    
    sqlite3_bind_blob(addStmt, 1, [matrixData bytes], (int)[matrixData length], SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 2, [gesture.gestureID UTF8String], -1, SQLITE_TRANSIENT);
    
    sqlite3_bind_int(addStmt, 3, 1000);
    
    if(SQLITE_DONE != sqlite3_step(addStmt)) {
      //  NSAssert1(0, @"Error while inserting data %s", sqlite3_errmsg(database));
        NSLog(@"sqlite done STOP");
        return NO;
    }
    
    else
        gesture.databaseID = sqlite3_last_insert_rowid(database);
    
    sqlite3_reset(addStmt);
    return YES;
}

- (void) printAllGestures{
    NSLog(@"printAllGestures:");
    
    if ((self.gestures == nil)) {
        NSLog(@"Nothing to print");
        return;
    }
    
    NSLog(@"got some to print");
    NSUInteger i;
    NSUInteger count = [self.gestures count];
    NSLog(@"Gestures count: %lu:",(unsigned long)count);
    //NSLog(@"%@: printing %d gestures",[self class],count);
    
    for (i = 0; i < count; i++) {
        Gesture * gesture = [self.gestures objectAtIndex:i];
        
        [gesture printGestureWithTrace: YES];
    }
}

-(void) checkAndCreateDatabase{
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
    BOOL success;
    
    // Create a FileManager object, we will use this to check the status
    // of the database and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the database has already been created in the users filesystem
    success = [fileManager fileExistsAtPath:self.path];
    
    // If the database already exists then return without doing anything
    if(success) {
        NSLog(@"%@: DB file: %@ found under path: %@",[self class],self.filename,self.path);
        return;
    };
    
    // If not then proceed to copy the database from the application to the users filesystem
    
    // Get the path to the database in the application package
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.filename];
    
    // Copy the database from the package to the users filesystem
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.path error:nil];
    
    NSLog(@"%@: NO DB file: %@ found under path: %@",[self class],self.filename,self.path);
    NSLog(@"%@: Creating new DB file: %@",[self class],self.path);
    
    
    
}

-(void) readGesturesFromDatabase {
    
    self.gestures = [[NSMutableArray alloc] init];
    self.gestureDict = [[NSMutableDictionary alloc] init];
    
    // Open the database from the users filessytem
    NSLog(@" - %@",self.path);
    NSLog(@" + %@",self.path);
    if(sqlite3_open([self.path UTF8String], &database) == SQLITE_OK) {
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = "SELECT * FROM gestureTraces ORDER BY gestureID";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            NSLog(@"%@: executed statement..", [self class]);
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                //NSLog(@"%@: Read the data from the result row...", [self class]);
                NSInteger databaseID = sqlite3_column_int(compiledStatement, 0);
                NSData * dataForTrace = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 1) length: sqlite3_column_bytes(compiledStatement, 1)];
                NSString *gestureID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
#pragma mark TODO
                NSDate * date = [NSDate date];//sqlite3_column_int(compiledStatement, 3);
                // Create a new animal object with the data from the database
                Matrix *trace = [self getMatrixFromData:dataForTrace];
                Gesture  *aGesture = [[Gesture alloc] initWithName:gestureID databaseID:databaseID creationDate: date andTrace:trace];
                
                // Add the animal object to the animals Array
                [self addGestureToArray:aGesture];
              
            }
        }
        NSLog(@"%@: found %lu Gestures in DB", [self class],(unsigned long)[self.gestures count]);
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
        
    }
    //	sqlite3_close(database);
    
}
#pragma mark Conversion Helper Methods
- (Matrix*) getMatrixFromData: (NSData*) data {
    NSString * dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray * rowsArray = [dataString componentsSeparatedByString:@";"];
    
    int max = (int)[rowsArray count];
    Matrix * gestureTrace = [[Matrix alloc] initMatrixWithRows:max andCols:3];
    
    NSUInteger i, count = [rowsArray count];
    for (i = 0; i < count; i++) {
        NSString * aRow = [rowsArray objectAtIndex:i];
        NSArray * values = [aRow componentsSeparatedByString:@" "];
        gestureTrace.data[i][0] = [[values objectAtIndex:0] floatValue];
        gestureTrace.data[i][1] = [[values objectAtIndex:1] floatValue];
        gestureTrace.data[i][2] = [[values objectAtIndex:2] floatValue];
        NSLog(@"values: %@",values[0]);
    }
    return gestureTrace;
}

- (NSData*) getDataFromMatrix: (Matrix*) matrix{
    
    NSMutableString * out = [[NSMutableString alloc] initWithString: @""];
    NSString * sep = @";";
    for (int j = 0; j < matrix.rows; j++) {
        
        for (int i = 0; i < matrix.cols; i++) {
            switch (i) {
                case (2):
                    [out appendFormat: @"%f",matrix.data[j][i]];
                    if(!(j == matrix.rows-1))
                        [out appendString:sep];
                    break;
                default:
                    [out appendFormat: @"%f ",matrix.data[j][i]];
                    break;
            }
        }
    }
    
    return [out dataUsingEncoding: NSASCIIStringEncoding];
}

- (void) deleteGesture:(int) databaseID  {
    
    if(deleteStmt == nil) {
        const char *sql = "DELETE FROM gestureTraces where id_ = ?";
        if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    }
    
    //When binding parameters, index starts from 1 and not zero.
    sqlite3_bind_int(deleteStmt, 1, databaseID);
    
    if (SQLITE_DONE != sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
    
    
    sqlite3_reset(deleteStmt);
    [self readGesturesFromDatabase];
}
- (void) deleteGesturesWithNames:(NSString*) _name  {
    
    if(deleteStmt == nil) {
        const char *sql = "DELETE FROM gestureTraces where gestureID = ?";
        if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    }
    
    //When binding parameters, index starts from 1 and not zero.
    //sqlite3_bind_text(deleteStmt, 1, _name);
    sqlite3_bind_text(deleteStmt, 1, [_name UTF8String], (int)[_name length] , SQLITE_TRANSIENT);
    if (SQLITE_DONE != sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
    
    
    sqlite3_reset(deleteStmt);
    [self readGesturesFromDatabase];
}

+ (void) finalizeStatements {
    
    if(database) sqlite3_close(database);
    if(deleteStmt) sqlite3_finalize(deleteStmt);
    if(addStmt) sqlite3_finalize(addStmt);
}

@end


