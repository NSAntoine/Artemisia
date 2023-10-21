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

NS_ASSUME_NONNULL_BEGIN

@interface SystemUtilites : NSObject

@property (class, readonly) SystemUtilites *sharedUtilities NS_SWIFT_NAME(shared);

-(float)currentVolume;

-(bool)setVolume: (float)newValue;
-(float)decreaseVolume: (bool)fractional;
-(float)increaseVolume: (bool)fractional;

@property BOOL isAudioMuted;

-(AudioDeviceID)audioDeviceID;

-(float)displayBrightnessWithDisplayID:  (CGDirectDisplayID)displayID;

-(bool)setBrightnessWithDisplayID:       (CGDirectDisplayID)displayID newValue: (float)newValue;
-(float)increaseBrightnessWithDisplayID: (CGDirectDisplayID)displayID isFractional: (bool)isFractional;
-(float)decreaseBrightnessWithDisplayID: (CGDirectDisplayID)displayID isFractional: (bool)isFractional;

@end

NS_ASSUME_NONNULL_END

#endif /* SystemUtilities_h */
