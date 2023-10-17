//
//  main.m
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
    }
    
    AppDelegate *del = [AppDelegate sharedDelegate];
    NSApplication.sharedApplication.delegate = del;
    return NSApplicationMain(argc, argv);
}
