//
//  MovementDBHandler.m
//  GeoTracker
//
//  Created by Jacob Hohisel on 5/12/15.
//  Copyright (c) 2015 Jacob Hohisel. All rights reserved.
//

#import "MovementDBHandler.h"

#define filename @"geotracker.db"


@interface MovementDBHandler ()

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSString *docsDirectory;
@property (nonatomic, strong) NSString *database;
@property (nonatomic, strong) NSMutableArray *columnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

- (NSArray *)loadDataFromDB:(NSString *)query;
- (void)executeQuery:(NSString *)query;

@end


@implementation MovementDBHandler
@synthesize docsDirectory, database, columnNames, affectedRows, lastInsertedRowID, results;

- (id)init {
    
    self = [super init];
    if (self) {
        
        // Set path to application document directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        [self setDocsDirectory:[paths objectAtIndex:0]];
        
        // Set database filename
        [self setDatabase:filename];
        
        // Copy the file if it doesn't already exist
        NSString *filePath = [[self docsDirectory] stringByAppendingPathComponent:[self database]];
        NSError *copyFileError;
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self database]];
            [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:filePath error:&copyFileError];
            if (copyFileError) {
                NSLog(@"%@", copyFileError);
            }
        }
    }
    return self;
}

// Public methods
- (BOOL)addMovement:(MovementData *)location {
    
    [self executeQuery:[NSString stringWithFormat:@"insert into movement values(%f, %f, %f, \'%@\', \'%@\', \'%@\')",
                        [location latitude],
                        [location longitude],
                        [location speed],
                        [location heading],
                        [location userid],
                        [location timestamp]]];
    if ([self affectedRows] != 0) {
        NSLog(@"Affected rows: %d", [self affectedRows]);
        return true;
    }
    return false;
}

- (NSArray *)getAllMovement {
    
    return [self loadDataFromDB:@"select * from movement"];
}

- (void)deleteAllMovement {
    
    [self executeQuery:@"delete from movement"];
    
}
//

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)isExecutable {
    
    sqlite3 *db;
    NSString *databasePath = [[self docsDirectory] stringByAppendingPathComponent:[self database]];
    
    // Initialize results array
    if ([self results] != nil) {
        [[self results] removeAllObjects];
        [self setResults:nil];
    }
    [self setResults:[[NSMutableArray alloc] init]];
    
    // Initialize column array
    if ([self columnNames] != nil) {
        [[self columnNames] removeAllObjects];
        [self setColumnNames:nil];
    }
    [self setColumnNames:[[NSMutableArray alloc] init]];
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &db);
    if (openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        
        BOOL prepareStatementResult = sqlite3_prepare_v2(db, query, -1, &compiledStatement, NULL);
        if (prepareStatementResult == SQLITE_OK) {
            
            if (!isExecutable) {
                
                NSMutableArray *dataRow;
                
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    
                    dataRow = [[NSMutableArray alloc] init];
                    int numCols = sqlite3_column_count(compiledStatement);
                    for (int i = 0; i < numCols; i++) {
                        char *dataString = (char *)sqlite3_column_text(compiledStatement, i);
                        if (dataString != NULL) {
                            [dataRow addObject:[NSString stringWithUTF8String:dataString]];
                        }
                        if ([[self columnNames] count] != numCols) {
                            dataString = (char *)sqlite3_column_name(compiledStatement, i);
                            [[self columnNames] addObject:[NSString stringWithUTF8String:dataString]];
                        }
                    }
                    if ([dataRow count] > 0) {
                        [[self results] addObject:dataRow];
                    }
                }
            } else {
                BOOL executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    [self setAffectedRows:sqlite3_changes(db)];
                    [self setLastInsertedRowID:sqlite3_last_insert_rowid(db)];
                } else {
                    NSLog(@"Error executing query: %s", sqlite3_errmsg(db));
                }
            }
        } else {
            NSLog(@"Error opening database: %s", sqlite3_errmsg(db));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(db);
}

- (NSArray *)loadDataFromDB:(NSString *)query {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    [self runQuery:[query UTF8String] isQueryExecutable:false];
    for (NSArray *a in [self results]) {
        
        MovementData *row = [[MovementData alloc] initWithLatitude:[[a objectAtIndex:0] doubleValue]
                                                         longitude:[[a objectAtIndex:1] doubleValue]
                                                             speed:[[a objectAtIndex:2] doubleValue]
                                                           heading:[a objectAtIndex:3]
                                                            userid:[a objectAtIndex:4]
                                                         timestamp:[a objectAtIndex:5]];
        [locations addObject:row];
    }
    return locations;
    
}

- (void)executeQuery:(NSString *)query {
    
    [self runQuery:[query UTF8String] isQueryExecutable:true];
    
}

@end
