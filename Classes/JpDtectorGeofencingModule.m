/**
 * Copyright (c) 2014 by Hiroki Arai
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "JpDtectorGeofencingModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation JpDtectorGeofencingModule

CLLocationManager *_locationManager;
NSMutableArray *geofences;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
  return @"08aa450e-02f1-4346-8823-ce247f44dc4d";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
  return @"jp.dtector.geofencing";
}

#pragma mark Lifecycle

-(void)startup
{
  // this method is called when the module is first loaded
  // you *must* call the superclass
  [super startup];
  geofences = [[NSMutableArray alloc] init];

  NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
  // this method is called when the module is being unloaded
  // typically this is during shutdown. make sure you don't do too
  // much processing here or the app will be quit forceably

  // you *must* call the superclass
  [super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
  // release any resources that have been retained by the module
  if (_locationManager) {
    [_locationManager release];
  }
  [geofences release];
  [super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
  // optionally release any resources that can be dynamically
  // reloaded once memory is available - such as caches
  [super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count { }

-(void)_listenerRemoved:(NSString *)type count:(int)count { }

#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"[INFO] Entered Region - %@", region.identifier);

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                       region.identifier, @"identifier", nil];
    [self fireEvent:@"enter" withObject:event];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"[INFO] Exited Region - %@", region.identifier);

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                       region.identifier, @"identifier", nil];
    [self fireEvent:@"exit" withObject:event];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"[INFO] Started monitoring %@ region", region.identifier);

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                       region.identifier, @"identifier", nil];
    [self fireEvent:@"monitor" withObject:event];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"[INFO] Failed to monitoring region \"%@\" (%@)", region.identifier, error);

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                       region.identifier, @"identifier",
                       [error localizedDescription], @"error", nil];
    [self fireEvent:@"fail" withObject:event];
}

#pragma geoFenging internal

- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled] && [CLLocationManager regionMonitoringEnabled]) {
        NSLog(@"[WARN] %@",@"You need to enable location services to use this app.");
        return;
    }

    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];

    NSLog(@"[INFO] %@",@"initialized location manager.");
}

- (BOOL) geoFencingAvailable {

    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
        return false;
    }

    if(![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"[WARN] %@",@"This app requires region monitoring features which are unavailable on this device.");
        return false;
    }

    return true;
}

- (void) startRegionMonitoring {
    if ([self geoFencingAvailable]) {
      return;
    }

    for(CLRegion *geofence in geofences) {
        [_locationManager startMonitoringForRegion:geofence];
    }
}

- (void) stopRegionMonitoring {
    if ([self geoFencingAvailable]) {
      return;
    }

    for(CLRegion *geofence in geofences) {
        [_locationManager stopMonitoringForRegion:geofence];
    }
}

#pragma Public APIs

-(void)start:(id)args
{
}

-(void)addRegion:(id)args
{
    ENSURE_UI_THREAD(addRegion, args);

    if (!_locationManager) {
      [self initializeLocationManager];
    }

    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *identifier;
    NSNumber *latitude;
    NSNumber *longitude;
    NSNumber *radius;

    ENSURE_ARG_OR_NIL_FOR_KEY(identifier, args, @"identifier", NSString);
    ENSURE_ARG_OR_NIL_FOR_KEY(latitude, args, @"latitude", NSNumber);
    ENSURE_ARG_OR_NIL_FOR_KEY(longitude, args, @"longitude", NSNumber);
    ENSURE_ARG_OR_NIL_FOR_KEY(radius, args, @"radius", NSNumber);

    CLLocationDegrees lat = [latitude doubleValue];
    CLLocationDegrees lng =[longitude doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(lat, lng);

    CLLocationDistance regionRadius = [radius doubleValue];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                               radius:regionRadius
                                                           identifier:identifier];
    [geofences addObject:region];

    [_locationManager startMonitoringForRegion:region];

    NSLog(@"[INFO] %@ added.", region);
}

-(void)removeRegion:(id)identifier
{
    ENSURE_SINGLE_ARG(identifier, NSString);

    NSMutableArray *reservations = [[[NSMutableArray alloc] init] autorelease];
    for (CLRegion *region in [[_locationManager monitoredRegions] allObjects]) {
        if ([region.identifier isEqualToString:identifier]) {
            [_locationManager stopMonitoringForRegion:region];
            [reservations addObject:region];
        }
    }
    for (CLRegion *region in reservations) {
        [geofences removeObject:region];
        NSLog(@"[INFO] %@ removed.", region);
    }
}

-(id)monitoredRegions:(id)args
{
    NSArray *allRegions = [[_locationManager monitoredRegions] allObjects];
    NSMutableArray *regionDictionaryArray = [[[NSMutableArray alloc] init] autorelease];
    for (id region in allRegions) {
        NSDictionary *jsonRegion = [NSDictionary
          dictionaryWithObjectsAndKeys:NUMDOUBLE(((CLRegion *)region).center.latitude), @"lat",
          NUMDOUBLE(((CLRegion *)region).center.longitude), @"lng",
          NUMDOUBLE(((CLRegion *)region).radius), @"radius",
          ((CLRegion *)region).identifier, @"identifier",
          nil];

        [regionDictionaryArray addObject:jsonRegion];
    }
    return regionDictionaryArray;
}

@end
