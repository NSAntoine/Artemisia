//
//  AppDelegate.m
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import "AppDelegate.h"
#import "EventMonitor.h"
#import "WindowController.h"
#import "DesktopViewController.h"

@implementation AppDelegate

+ (instancetype)sharedDelegate {
    static AppDelegate *del;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        del = [[AppDelegate alloc] init];
    });
    
    return del;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [NSApplication.sharedApplication setActivationPolicy:NSApplicationActivationPolicyAccessory];
    
    [[EventMonitor sharedMonitor] startMonitoring];
    
    WindowController *ctrl = [WindowController controllerWithKind:WindowControllerWindowKindBar];
    self.desktopVC = (DesktopViewController *)ctrl.contentViewController;
    [ctrl showWindow:self];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.image = [NSImage imageWithSystemSymbolName:@"slider.horizontal.below.rectangle" accessibilityDescription:nil];
    
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *itm = [[NSMenuItem alloc] init];
    itm.view = [self titleView];
    [menu addItem:itm];
    
    [menu addItem: NSMenuItem.separatorItem];
    
    NSMenuItem *posItm = [[NSMenuItem alloc] initWithTitle:@"HUD Position" action:nil keyEquivalent:@""];
    
    posItm.submenu = [self positionMenu];
    
    [menu addItem:posItm];
    
    [menu addItem: NSMenuItem.separatorItem];
    NSMenuItem *quit = [menu addItemWithTitle:@"Quit" action:@selector(terminateApp) keyEquivalent:@"q"];
    quit.target = self;
    
    self.statusItem.menu = menu;
}

- (NSMenu *)positionMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    
    DesktopViewPosition currPos = [DesktopViewController HUDPosition];
    
    NSMenuItem *topLeft = [menu addItemWithTitle:@"Top Left" action:@selector(positionMenuItemAction:) keyEquivalent:@""];
    topLeft.tag = DesktopViewPositionTopLeft;
    topLeft.state = currPos == DesktopViewPositionTopLeft ? NSControlStateValueOn : NSControlStateValueOff;
    
    NSMenuItem *topRight = [menu addItemWithTitle:@"Top Right (Default)" action:@selector(positionMenuItemAction:) keyEquivalent:@""];
    topRight.tag = DesktopViewPositionTopRight;
    topRight.state = currPos == DesktopViewPositionTopRight ? NSControlStateValueOn : NSControlStateValueOff;
    
    NSMenuItem *bottomLeft = [menu addItemWithTitle:@"Bottom Left" action:@selector(positionMenuItemAction:) keyEquivalent:@""];
    bottomLeft.tag = DesktopViewPositionBottomLeft;
    bottomLeft.state = currPos == DesktopViewPositionBottomLeft ? NSControlStateValueOn : NSControlStateValueOff;
    
    NSMenuItem *bottomRight = [menu addItemWithTitle:@"Bottom Right" action:@selector(positionMenuItemAction:) keyEquivalent:@""];
    bottomRight.tag = DesktopViewPositionBottomRight;
    bottomRight.state = currPos == DesktopViewPositionBottomRight ? NSControlStateValueOn : NSControlStateValueOff;
    
    return menu;
}

-(void)positionMenuItemAction: (NSMenuItem *)item {
    [[NSUserDefaults standardUserDefaults] setInteger:item.tag forKey:@"DesktopViewPosition"];
    item.parentItem.submenu = [self positionMenu];
}

-(void)terminateApp {
    [NSApplication.sharedApplication terminate:nil];
}

-(NSView *)titleView {
    NSView *v = [[NSView alloc] init];
    [v setFrameSize:CGSizeMake(150, 20)];
    
    NSTextField *titleField = [NSTextField labelWithString: NSRunningApplication.currentApplication.localizedName ];
    titleField.translatesAutoresizingMaskIntoConstraints = NO;
    
    titleField.font = [NSFont preferredFontForTextStyle:NSFontTextStyleHeadline options:@{}];
    
    [v addSubview:titleField];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleField.topAnchor constraintEqualToAnchor:v.topAnchor constant:2.5],
        [titleField.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:14]
    ]];
    
    return v;
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
