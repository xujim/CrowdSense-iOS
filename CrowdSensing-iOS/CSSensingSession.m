//
//  CSSensingSession.m
//  CrowdSensing-iOS
//
//  Created by Minos Katevas on 13/07/2015.
//  Copyright (c) 2015 Kleomenis Katevas. All rights reserved.
//

#import "CSSensingSession.h"
#import "CSModelWriter.h"
#import "CSRecordingLogModelWriter.h"

#define TOTAL_SENSOR_MODULES 11

@interface CSSensingSession ()

@property (nonatomic, strong) NSURL* folderPath;
@property (nonatomic, strong) NSMutableArray *modelWriters;
@property (nonatomic, strong) CSRecordingLogModelWriter *recordingLogModelWriter;

@end

@implementation CSSensingSession

- (instancetype)initWithFolderName:(NSString *)folderName
{
    if (self = [super init])
    {
        // Init SensingKitLib
        self.sensingKitLib = [SensingKitLib sharedSensingKitLib];
        
        self.folderPath = [self createFolderWithName:folderName];
        
        self.modelWriters = [[NSMutableArray alloc] initWithCapacity:TOTAL_SENSOR_MODULES];
        self.recordingLogModelWriter = [[CSRecordingLogModelWriter alloc] initWithFilename:@"RecordingLog.csv"
                                                                                    inPath:self.folderPath];
    }
    return self;
}

- (NSURL *)createFolderWithName:(NSString *)folderName
{
    NSError *error = nil;
    
    NSURL *folderPath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:folderName];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:folderPath
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    
    if (error != nil) {
        NSLog(@"Error creating directory: %@", error);
    }
    
    return folderPath;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (CSModelWriter *)getModuleWriterWithType:(SKSensorModuleType)moduleType
{
    for (CSModelWriter *moduleWriter in self.modelWriters) {
        if (moduleWriter.moduleType == moduleType) { return moduleWriter; }
    }
    
    return nil;
}

- (void)enableSensorWithType:(SKSensorModuleType)moduleType
{
    // Get the csv header
    NSString *header = [self.sensingKitLib csvHeaderForSensorModule:moduleType];
    
    // Create ModelWriter
    NSString *filename = [[self getSensorModuleInString:moduleType] stringByAppendingString:@".csv"];
    CSModelWriter *modelWriter = [[CSModelWriter alloc] initWithSensorModuleType:moduleType
                                                                      withHeader:header
                                                                    withFilename:filename
                                                                          inPath:self.folderPath];
    
    // Register and Subscribe sensor
    [self.sensingKitLib registerSensorModule:moduleType];
    [self.sensingKitLib subscribeSensorDataListenerToSensor:moduleType
                                                withHandler:^(SKSensorModuleType moduleType, SKSensorData *sensorData) {
                                                    
                                                    // Feed the writer with data
                                                    [modelWriter readData:sensorData];
                                                }];
    
    // Add sensorType and modelWriter to the arrays
    [self.modelWriters addObject:modelWriter];
}

- (void)disableSensorWithType:(SKSensorModuleType)moduleType
{
    [self.sensingKitLib deregisterSensorModule:moduleType];
    
    // Search for the moduleWriter in the Array
    CSModelWriter *moduleWriter = [self getModuleWriterWithType:moduleType];
    
    // Close the fileWriter
    [moduleWriter close];
    
    // Remove fileWriter
    [self.modelWriters removeObject:moduleWriter];
}

- (void)disableAllRegisteredSensors
{
    for (int i = 0; i < TOTAL_SENSOR_MODULES; i++)
    {
        SKSensorModuleType moduleType = i;
        
        if ([self isSensorEnabled:moduleType]) {
            [self disableSensorWithType:moduleType];
        }
    }
}

- (BOOL)isSensorAvailable:(SKSensorModuleType)moduleType
{
     return [self.sensingKitLib isSensorModuleAvailable:moduleType];
}

- (BOOL)isSensorEnabled:(SKSensorModuleType)moduleType
{
    return [self.sensingKitLib isSensorModuleRegistered:moduleType];
}

- (void)start
{
    [self.sensingKitLib startContinuousSensingWithAllRegisteredSensors];
}

- (void)stop
{
    [self.sensingKitLib stopContinuousSensingWithAllRegisteredSensors];
}

- (void)close
{
    NSLog(@"Close Session");
    
    [self.recordingLogModelWriter close];
}

- (NSString *)getSensorModuleInString:(SKSensorModuleType)moduleType
{
    switch (moduleType) {
            
        case Accelerometer:
            return @"Accelerometer";
            
        case Gyroscope:
            return @"Gyroscope";
            
        case Magnetometer:
            return @"Magnetometer";
            
        case DeviceMotion:
            return @"DeviceMotion";
            
        case Activity:
            return @"Activity";
            
        case Pedometer:
            return @"Pedometer";
            
        case Altimeter:
            return @"Altimeter";
            
        case Battery:
            return @"Battery";
            
        case Location:
            return @"Location";
            
        case iBeaconProximity:
            return @"iBeaconProximity";
            
        case EddystoneProximity:
            return @"EddystoneProximity";
            
        default:
            return [NSString stringWithFormat:@"Unknown SensorModule: %li", (long)moduleType];
            abort();
    }
}

- (void)addRecordingLog:(NSString *)recordingLog;
{
    [self.recordingLogModelWriter addRecordingLog:recordingLog];
}

@end
