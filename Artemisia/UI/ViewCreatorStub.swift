//
//  ViewCreatorStub.swift
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

import SwiftUI
import Cocoa

class CustomHostingView: NSHostingView<EventBarView> {
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        newWindow?.hasShadow = false
    }
}

@objc
class ViewCreatorStub: NSObject {
    @objc
    static func makeView(withKind kind: EventBarKind) -> NSView {
        return CustomHostingView(rootView: EventBarView(kind: kind))
    }
}
