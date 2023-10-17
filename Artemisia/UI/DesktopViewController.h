//
//  DesktopViewController.h
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#ifndef DesktopViewController_h
#define DesktopViewController_h

#import <Cocoa/Cocoa.h>
#import "EventKind.h"

typedef NS_ENUM(NSUInteger, DesktopViewPosition) {
    DesktopViewPositionTopLeft,
    DesktopViewPositionTopRight,
    DesktopViewPositionBottomLeft,
    DesktopViewPositionBottomRight,
};

@interface DesktopViewController: NSViewController

@property NSView *barView;
@property NSTimer *timer;

-(void)retainOrAddBarViewWithKind: (EventBarKind)kind;
+(DesktopViewPosition)HUDPosition;

@end

#endif /* DesktopViewController_h */
