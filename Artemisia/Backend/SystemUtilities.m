//
//  SystemUtilities.m
//  Artemisia
//
//  Created by Serena on 15/10/2023.
//  

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SystemUtilities.h"

/* Yes, they're both the same value */
#define SYSTEM_VOLUME_CHANGE_CONSTANT (0.0625)
#define BRIGHTNESS_CHANGE_CONSTANT (0.0625)

#define NORMALIZE_VALUE(value, min, max) MIN(MAX(min, value), max);

WEAK_IMPORT_ATTRIBUTE
extern CGError DisplayServicesGetBrightness(CGDirectDisplayID display, float *brightness);

WEAK_IMPORT_ATTRIBUTE
extern CGError DisplayServicesSetBrightness(CGDirectDisplayID display, float brightness);

@implementation SystemUtilites

+ (instancetype)sharedUtilities {
    static SystemUtilites *utils;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[SystemUtilites alloc] init];
    });
    
    
    return utils;
}

- (AudioDeviceID)audioDeviceID {
    AudioObjectPropertyAddress address = {
        .mSelector = kAudioHardwarePropertyDefaultOutputDevice,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMain
    };
    
    if (!AudioObjectHasProperty(kAudioObjectSystemObject, &address)) {
        printf("%s: AudioObjectHasProperty is false\n", __func__);
    }
    
    uint32_t size = sizeof(AudioDeviceID);
    AudioObjectID result = kAudioObjectUnknown;
    /*OSStatus status = */AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, nil, &size, &result);
    return result;
}

-(float)currentVolume {
    uint32_t size = sizeof(Float32);
    float volume = 0;
    
    AudioDeviceID device = [self audioDeviceID];
    
    AudioObjectPropertyAddress addr = {
        .mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
        .mScope = kAudioDevicePropertyScopeOutput,
        .mElement = kAudioObjectPropertyElementMain
    };

    if (!AudioObjectHasProperty(device, &addr)) {
        printf("%s: AudioObjectHasProperty failed\n", __func__);
    }
    
    AudioObjectGetPropertyData(device, &addr, 0, nil, &size, &volume);
    
    return volume;
}

-(bool)setVolume: (float)newValue {
    AudioDeviceID device = [self audioDeviceID];
    // Normalize volume
    float volumeToSet = newValue;
    
    AudioObjectPropertyAddress address = {
      .mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
      .mScope = kAudioDevicePropertyScopeOutput,
      .mElement = kAudioObjectPropertyElementMain
    };
    
    if (!AudioObjectHasProperty(device, &address)) {
        printf("%s: AudioObjectHasProperty false\n", __func__);
        return false;
    }
    
    Boolean isSettable = true;
    uint32_t size = sizeof(volumeToSet);
    OSStatus status = AudioObjectIsPropertySettable(device, &address, &isSettable);
    if (status != noErr) {
        printf("AudioObjectIsPropertySettable returned status error\n");
        return false;
    }
    
    if (!isSettable) {
        printf("isSettable is false\n");
        return false;
    }
    
    OSStatus setStatus = AudioObjectSetPropertyData(device, &address, 0, nil, size, &volumeToSet);
    return setStatus == noErr;
}

- (float)volumeChangeAmount: (bool)fractionally {
    float fromDefaults = [NSUserDefaults.standardUserDefaults floatForKey:@"VolumeChangeAmount"];
    float final = (fromDefaults) ? fromDefaults : SYSTEM_VOLUME_CHANGE_CONSTANT;
    return fractionally ? final / 5 : final;
}

- (float)increaseVolume:(bool)fractional {
    float volume = [self currentVolume];
    
    float newValue = NORMALIZE_VALUE(volume + [self volumeChangeAmount:fractional], 0, 1);
    bool succeeded = [self setVolume: newValue];
    return succeeded ? newValue : volume;
}

- (float)decreaseVolume:(bool)fractional {
    float volume = [self currentVolume];
    
    float newValue = NORMALIZE_VALUE(volume - [self volumeChangeAmount:fractional], 0, 1);
    bool succeeded = [self setVolume: newValue];
    return succeeded ? newValue : volume;
}

- (BOOL)isAudioMuted {
    AudioDeviceID deviceID = [self audioDeviceID];
    
    uint32_t isMuted = 0;
    uint32_t size = sizeof(isMuted);
    AudioObjectPropertyAddress address = {
      .mSelector = kAudioDevicePropertyMute,
      .mScope = kAudioDevicePropertyScopeOutput,
      .mElement = kAudioObjectPropertyElementMain
    };
    
    if (!AudioObjectHasProperty(deviceID, &address)) {
        printf("%s: AudioObjectHasProperty false\n", __func__);
        return false;
    }
    
    AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &isMuted);
    
    return isMuted;
}

-(void)setIsAudioMuted:(BOOL)newValue {
    
    AudioDeviceID deviceID = [self audioDeviceID];
    AudioObjectPropertyAddress addr = {
        .mSelector = kAudioDevicePropertyMute,
        .mScope = kAudioDevicePropertyScopeOutput,
        .mElement = kAudioObjectPropertyElementMain
    };
    
    if (!AudioObjectHasProperty(deviceID, &addr)) {
        printf("%s: AudioObjectHasProperty returned false\n", __func__);
        return;
    }
    
    // (We actually need to do this)
    uint32_t new = newValue;
    
    AudioObjectSetPropertyData(deviceID, &addr, 0, nil, sizeof(new), &new);
}

- (float)_displayBrightnessIOKit {
    float brightness = 1.0f;
    io_iterator_t iterator;
    kern_return_t result =
    IOServiceGetMatchingServices(kIOMasterPortDefault,
                                 IOServiceMatching("IODisplayConnect"),
                                 &iterator);
    
    // If we were successful
    if (result == kIOReturnSuccess)
    {
        io_object_t service;
        
        while ((service = IOIteratorNext(iterator)))
        {
            IODisplayGetFloatParameter(service,
                                       kNilOptions,
                                       CFSTR(kIODisplayBrightnessKey),
                                       &brightness);
            
            // Let the object go
            IOObjectRelease(service);
        } 
    }
    
    return brightness;
}

- (float)displayBrightnessWithDisplayID:(CGDirectDisplayID)displayID {
    if (DisplayServicesGetBrightness) {
        float ret = 0;
        DisplayServicesGetBrightness(displayID, &ret);
        return ret;
    }
    
    return [self _displayBrightnessIOKit];
}

-(bool)setBrightnessWithDisplayID: (CGDirectDisplayID)displayID newValue: (float)newValue {
//    float new = MIN(MAX(0, newValue), 1);
    float new = newValue;
    if (DisplayServicesSetBrightness) {
        CGError error = DisplayServicesSetBrightness(CGMainDisplayID(), new);
        return (error == kCGErrorSuccess);
    } else {
        io_iterator_t iterator;
        kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                            IOServiceMatching("IODisplayConnect"),
                                                            &iterator);
        
        if (result != kIOReturnSuccess)
            return false;
        
        // If we were successful
        io_object_t service;
        while ((service = IOIteratorNext(iterator))) {
            IODisplaySetFloatParameter(service, kNilOptions, CFSTR(kIODisplayBrightnessKey), newValue);
            
            // Let the object go
            IOObjectRelease(service);
            
            break;
        }
        
        return true;
    }
}

-(float)brightnessChangeAmount: (bool)isFractional {
    return isFractional ? BRIGHTNESS_CHANGE_CONSTANT / 5 : BRIGHTNESS_CHANGE_CONSTANT;
}

- (float)increaseBrightnessWithDisplayID:(CGDirectDisplayID)displayID isFractional:(bool)isFractional {
    float cur = [self displayBrightnessWithDisplayID:displayID];
    
    float newValue = NORMALIZE_VALUE(cur + [self brightnessChangeAmount:isFractional], 0, 1);
    bool succeeded = [self setBrightnessWithDisplayID:CGMainDisplayID() newValue: newValue];
    return succeeded ? newValue : cur;
}

- (float)decreaseBrightnessWithDisplayID:(CGDirectDisplayID)displayID isFractional:(bool)isFractional {
    float cur = [self displayBrightnessWithDisplayID:displayID];
    
    float newValue = NORMALIZE_VALUE(cur - [self brightnessChangeAmount:isFractional], 0, 1)
    bool succeeded = [self setBrightnessWithDisplayID:CGMainDisplayID() newValue: newValue];
    
    return succeeded ? newValue : cur;
}
@end
