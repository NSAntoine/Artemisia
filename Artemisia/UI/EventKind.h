//
//  EventKind.h
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#ifndef EventKind_h
#define EventKind_h

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(NSUInteger, EventBarKind) {
    EventBarKindVolume,
    EventBarKindBrightness,
};

typedef NS_CLOSED_ENUM(NSUInteger, EventBarKindChange) {
    EventBarKindChangeIncrease,
    EventBarKindChangeDecrease,
    EventBarKindChangeMuted, // Only applies to audio
};


#endif /* EventKind_h */
