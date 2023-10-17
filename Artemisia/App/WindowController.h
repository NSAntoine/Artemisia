//
//  WindowController.h
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#ifndef WindowController_h
#define WindowController_h

#import <Cocoa/Cocoa.h>

typedef NS_CLOSED_ENUM(NSUInteger, WindowControllerWindowKind) {
    WindowControllerWindowKindBar,
};

@interface WindowController : NSWindowController

+(instancetype)controllerWithKind: (WindowControllerWindowKind)kind;

@end


#endif /* WindowController_h */
