//
//  WindowController.m
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import <Foundation/Foundation.h>
#import "DesktopViewController.h"
#import "WindowController.h"

@implementation WindowController
+ (instancetype)controllerWithKind:(WindowControllerWindowKind)kind {
    NSViewController *ctrller;
    
    switch (kind) {
    case WindowControllerWindowKindBar:
        ctrller = [[DesktopViewController alloc] init];
    }
    
    NSWindow *window = [NSWindow windowWithContentViewController:ctrller];
    WindowController *ret = [[WindowController alloc] initWithWindow:window];
    
    switch (kind) {
        case WindowControllerWindowKindBar:
            window.styleMask -= NSWindowStyleMaskTitled;
            window.backgroundColor = [NSColor clearColor];
//            window.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
            window.level = NSFloatingWindowLevel;
            window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
            [window setFrame:NSScreen.mainScreen.visibleFrame display:YES];
    }
    
    return ret;
}
@end
