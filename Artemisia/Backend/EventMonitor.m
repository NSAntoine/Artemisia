//
//  EventMonitor.m
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import <Foundation/Foundation.h>
#import "EventMonitor.h"
#import "AppDelegate.h"

CGEventType kCGEventSystemDefined = 14;

bool shouldSustainNSEvent(NSEvent *ev) {
    if (!ev)
        return false;
    return ev.subtype == NSEventSubtypeScreenChanged;
}

CGEventRef _eventMonitorCallback(CGEventTapProxy prox, CGEventType type, CGEventRef event, void * __nullable userInfo) {
    NSEvent *nsEvent = [NSEvent eventWithCGEvent:event];
    if (!shouldSustainNSEvent(nsEvent))
        return event;
    
    uint32_t keyCode = (nsEvent.data1 & 0xFFFF0000) >> 16;
    uint32_t keyFlags = (nsEvent.data1 & 0x0000FFFF);
    bool isKeyDown = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    
    if (isKeyDown) {
        switch (keyCode) {
            case NX_KEYTYPE_SOUND_DOWN:
                [EventMonitor.sharedMonitor updateWithKind: EventBarKindVolume change: EventBarKindChangeDecrease];
                return nil;
            case NX_KEYTYPE_SOUND_UP:
                [EventMonitor.sharedMonitor updateWithKind: EventBarKindVolume change: EventBarKindChangeIncrease];
                return nil;
            case NX_KEYTYPE_MUTE:
                [EventMonitor.sharedMonitor updateWithKind: EventBarKindVolume change:EventBarKindChangeMuted];
                return nil;
            case NX_KEYTYPE_BRIGHTNESS_DOWN:
                [EventMonitor.sharedMonitor updateWithKind: EventBarKindBrightness change: EventBarKindChangeDecrease];
                return nil;
            case NX_KEYTYPE_BRIGHTNESS_UP:
                [EventMonitor.sharedMonitor updateWithKind: EventBarKindBrightness change: EventBarKindChangeIncrease];
                return nil;
            default:
                break;
        }
    }
    
    return event;
}

@implementation EventMonitor

+ (instancetype)sharedMonitor {
    static EventMonitor *monitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[EventMonitor alloc] init];
    });
    
    return monitor;
}

- (void)updateWithKind:(EventBarKind)kind change:(EventBarKindChange)change {
    [AppDelegate.sharedDelegate.desktopVC retainOrAddBarViewWithKind:kind];
    
    if (self.updateCallback)
        self.updateCallback(kind, change);
}

- (void)startMonitoring {
    
    CFDictionaryRef opts = (__bridge CFDictionaryRef) @{
        (__bridge NSString *)kAXTrustedCheckOptionPrompt: @(true)
    };
    
    if (!AXIsProcessTrustedWithOptions(opts)) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.informativeText = [NSString stringWithFormat:@"In order to use %@, grant it Accessibility permissions in Settings (Privacy & Security -> Accessibility) and relaunch the app", NSRunningApplication.currentApplication.localizedName];;
        alert.messageText = @"Permissions Required";
        
        [alert runModal];
        return;
    }
    
    if (self.currentEventTap) {
        if (!CGEventTapIsEnabled(self.currentEventTap))
            CGEventTapEnable(self.currentEventTap, YES);
        return;
    }
    
    self.currentEventTap = CGEventTapCreate(kCGHIDEventTap,
                                            kCGHeadInsertEventTap,
                                            kCGEventTapOptionDefault,
                                            CGEventMaskBit(kCGEventSystemDefined), _eventMonitorCallback, nil);
    CGEventTapEnable(self.currentEventTap, YES);
    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, self.currentEventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
}

- (void)pauseMonitoring {
    if (self.currentEventTap) {
        CGEventTapEnable(self.currentEventTap, NO);
    }
}

@end
