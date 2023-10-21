//
//  EventBarView.swift
//  Artemisia
//
//  Created by Serena on 14/10/2023.
//  

import SwiftUI
import MacControlCenterUI

struct EventBarView: View {
    
    @State var kind: EventBarKind = .volume
    @State var currentValue: CGFloat = 0
//    @State var isMuted: Bool = false
//    @State var curentValueSetAutomatically: Bool = false
    
    var body: some View {
        mainView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BackgroundVisualEffectView())
            .cornerRadius(10)
            .onAppear {
                // fetch initial value
                initiallyFetchValues()
                
                EventMonitor.shared().updateCallback = { newValue, changeKind, isFractional in
                    self.kind = newValue
                    
                    withAnimation(Animation.smooth) {
                        switch newValue {
                        case .volume:
                            handleVolumeChange(change: changeKind, isFractional: isFractional)
                        case .brightness:
                            handleBrightnessChange(change: changeKind, isFractional: isFractional)
                        }
                    }
                }
            }
            .onChange(of: currentValue) { newValue in
                AppDelegate.shared().desktopVC.retainOrAddBarView(with: kind)
            }
            .shadow(radius: 10)
    }
    
    func initiallyFetchValues() {
        switch kind {
        case .volume:
            self.currentValue = SystemUtilites.shared.isAudioMuted ? 0 : CGFloat(SystemUtilites.shared.currentVolume())
        case .brightness:
            self.currentValue = CGFloat(SystemUtilites.shared.displayBrightness(withDisplayID: currentDisplayID()))
        }
    }
    
    func handleBrightnessChange(change: EventBarKindChange, isFractional: Bool) {
        switch change {
        case .increase:
            self.currentValue = CGFloat(SystemUtilites.shared.increaseBrightness(withDisplayID: currentDisplayID(), 
                                                                                            isFractional: isFractional))
        case .decrease:
            self.currentValue = CGFloat(SystemUtilites.shared.decreaseBrightness(withDisplayID: currentDisplayID(),
                                                                                            isFractional: isFractional))
        default:
            break
        }
        
//        print(SystemUtilites.shared.displayBrightness(withDisplayID: currentDisplayID()))
    }
    
    func currentDisplayID() -> CGDirectDisplayID {
        let screen = NSApplication.shared.windows.first { $0.contentView is NSHostingView<EventBarView> }?.screen ?? NSScreen.main
        
        // Try get current display ID
        // if that fails, just fall back to the *main* display ID
        return (screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) ?? CGMainDisplayID()
    }
    
    func handleVolumeChange(change: EventBarKindChange, isFractional: Bool) {
        switch change {
        case .increase:
            if SystemUtilites.shared.isAudioMuted { SystemUtilites.shared.isAudioMuted = false }
            self.currentValue = CGFloat(SystemUtilites.shared.increaseVolume(isFractional))
        case .decrease:
            if SystemUtilites.shared.isAudioMuted { SystemUtilites.shared.isAudioMuted = false }
            self.currentValue = CGFloat(SystemUtilites.shared.decreaseVolume(isFractional))
        case .muted:
            SystemUtilites.shared.isAudioMuted.toggle()
            
            self.currentValue = CGFloat(SystemUtilites.shared.isAudioMuted ? 0 : SystemUtilites.shared.currentVolume())
        }
    }
    
    @ViewBuilder
    var mainView: some View {
        switch kind {
        case .brightness:
            HStack {
                Text("Brightness")
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            MenuSlider(value: $currentValue, image: BrightnessSliderImage()) { /* newValue from gesture, so we can't use onChange(of:)*/ newValue in
                SystemUtilites.shared.setBrightnessWithDisplayID(currentDisplayID(), newValue: Float(newValue))
            }
                .padding(.horizontal)
        case .volume:
            HStack {
                Text("Volume")
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            MenuVolumeSlider(value: $currentValue) { newValue in
                if SystemUtilites.shared.isAudioMuted { SystemUtilites.shared.isAudioMuted = false }
                SystemUtilites.shared.setVolume(Float(newValue))
            }
                .padding(.horizontal)
        }
    }
}

fileprivate struct BrightnessSliderImage: MenuSliderImage {
    func image(for value: CGFloat, oldValue: CGFloat?, force: Bool) -> MenuSliderImageUpdate? {
        return .newImage(image)
    }
    
    let image = Image(systemName: "sun.max.fill")
    
    func transform(image: Image, for value: CGFloat) -> AnyView? {
        return AnyView(
            image.resizable()
            .frame(width: 15, height: 15)
            .padding(.horizontal, 4)
        )
    }
}

fileprivate struct BackgroundVisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        let v = NSVisualEffectView()
        v.material = .menu
        v.state = .active
        
        return v
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
}
