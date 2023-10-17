//
//  SystemUtilities.h
//  Artemisia
//
//  Created by Serena on 15/10/2023.
//  

#ifndef SystemUtilities_h
#define SystemUtilities_h

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>

@interface SystemUtilites : NSObject
+(instancetype)sharedUtilities;

-(float)currentVolume;

-(bool)setVolume: (float)newValue;
-(float)decreaseVolume;
-(float)increaseVolume;

@property BOOL isAudioMuted;

-(AudioDeviceID)audioDeviceID;

-(float)displayBrightnessWithDisplayID:  (CGDirectDisplayID)displayID;

-(bool)setBrightnessWithDisplayID:       (CGDirectDisplayID)displayID newValue: (float)newValue;
-(float)increaseBrightnessWithDisplayID: (CGDirectDisplayID)displayID;
-(float)decreaseBrightnessWithDisplayID: (CGDirectDisplayID)displayID;

@end

#endif /* SystemUtilities_h */
