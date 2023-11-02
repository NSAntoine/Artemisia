//
//  DesktopViewController.m
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "DesktopViewController.h"
#import "EventMonitor.h"
#import "AppDelegate.h"
#import "Artemisia-Swift.h"

@implementation DesktopViewController

- (void)loadView {
    self.view = [[NSView alloc] init];
    
    [self.view setFrame:NSScreen.mainScreen.frame];
}



- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)retainOrAddBarViewWithKind: (EventBarKind)kind {
    
    if (!self.barView)
        [self addBarViewWithKind:kind];
    
    if (self.timer)
        [self removeTimer];
    
    
    [self instantiateTimer];
}

-(void)instantiateTimer {
    // Remove bar view & animate removal
    self.timer = [NSTimer timerWithTimeInterval:1.50 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.25;
            context.allowsImplicitAnimation = YES;
            
            self.barView.animator.alphaValue = 0;
            [self.barView removeFromSuperview];
            self.barView = nil;
        }];
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

+(DesktopViewPosition)HUDPosition {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"DesktopViewPosition"];
    return (num != nil) ? [num unsignedIntegerValue] : DesktopViewPositionTopRight;
}

-(void)addBarViewWithKind: (EventBarKind)kind {
    self.barView = [ViewCreatorStub makeViewWithKind:kind];
    
    self.barView.translatesAutoresizingMaskIntoConstraints = NO;
    self.barView.alphaValue = 0;
    [self.view addSubview:self.barView];
   
    // Activate Height & Width
    [NSLayoutConstraint activateConstraints:@[
        [self.barView.widthAnchor constraintEqualToConstant:340],
        [self.barView.heightAnchor constraintEqualToConstant:75]
    ]];
    
    DesktopViewPosition pos = [DesktopViewController HUDPosition];
    
//    printf("isVisible: %s\n", [NSMenu menuBarVisible] ? "Yes" : "No");
    CGFloat topConst = 40;
    switch (pos) {
        case DesktopViewPositionTopLeft:
            [NSLayoutConstraint activateConstraints:@[
                [self.barView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
                [self.barView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:topConst],
            ]];
            break;
        case DesktopViewPositionTopRight:
            [NSLayoutConstraint activateConstraints:@[
                [self.barView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
                [self.barView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:topConst],
            ]];
            break;
        case DesktopViewPositionBottomLeft:
            [NSLayoutConstraint activateConstraints:@[
                [self.barView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
                [self.barView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-30],
            ]];
            break;
        case DesktopViewPositionBottomRight:
            [NSLayoutConstraint activateConstraints:@[
                [self.barView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
                [self.barView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-30],
            ]];
            break;
        default:
            break;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.40;
        context.allowsImplicitAnimation = YES;
        
        self.barView.animator.alphaValue = 1;
    }];
}

@end
