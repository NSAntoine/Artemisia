//
//  EventMonitor.h
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#ifndef EventMonitor_h
#define EventMonitor_h

#import <Cocoa/Cocoa.h>
#import "EventKind.h"

typedef void(^EventKindUpdate)(EventBarKind, EventBarKindChange, bool);

@interface EventMonitor : NSObject

+(nonnull instancetype)sharedMonitor;

@property (nullable) CFMachPortRef currentEventTap;
@property (nullable) EventKindUpdate updateCallback;

-(void)startMonitoring;
-(void)pauseMonitoring;
-(void)updateWithKind: (EventBarKind) kind change: (EventBarKindChange)change isFractional: (bool)isFractional;

@end

#endif /* EventMonitor_h */
