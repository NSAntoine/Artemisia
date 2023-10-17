//
//  AppDelegate.h
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import <Cocoa/Cocoa.h>
#import "DesktopViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property DesktopViewController *desktopVC;
@property NSStatusItem *statusItem;

+(instancetype)sharedDelegate;


@end

