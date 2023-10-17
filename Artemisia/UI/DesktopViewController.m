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

-(void)addBarViewWithKind: (EventBarKind)kind {
    self.barView = [ViewCreatorStub makeViewWithKind:kind];
    
    self.barView.translatesAutoresizingMaskIntoConstraints = NO;
    self.barView.alphaValue = 0;
    [self.view addSubview:self.barView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.barView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.barView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30],
        
        [self.barView.widthAnchor constraintEqualToConstant:340],
        [self.barView.heightAnchor constraintEqualToConstant:75],
    ]];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.40;
        context.allowsImplicitAnimation = YES;
        
        self.barView.animator.alphaValue = 1;
    }];
}

@end
