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
                
                EventMonitor.shared().updateCallback = { newValue, changeKind in
                    self.kind = newValue
                    
                    withAnimation(Animation.smooth) {
                        switch newValue {
                        case .volume:
                            self.currentValue = CGFloat(SystemUtilites.sharedUtilities().currentVolume())
                            handleVolumeChange(change: changeKind)
                        case .brightness:
                            self.currentValue = CGFloat(SystemUtilites.sharedUtilities().displayBrightness(withDisplayID: currentDisplayID()))
                            handleBrightnessChange(change: changeKind)
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
            self.currentValue = SystemUtilites.sharedUtilities().isAudioMuted ? 0 : CGFloat(SystemUtilites.sharedUtilities().currentVolume())
        case .brightness:
            self.currentValue = CGFloat(SystemUtilites.sharedUtilities().displayBrightness(withDisplayID: currentDisplayID()))
        }
    }
    
    func setCurrentValueAuto(to new: CGFloat) {
        self.currentValue = new
    }
    
    func handleBrightnessChange(change: EventBarKindChange) {
        switch change {
        case .increase:
            setCurrentValueAuto(to: CGFloat(SystemUtilites.sharedUtilities().increaseBrightness(withDisplayID: currentDisplayID())))
        case .decrease:
            setCurrentValueAuto(to: CGFloat(SystemUtilites.sharedUtilities().decreaseBrightness(withDisplayID: currentDisplayID())))
        default:
            break
        }
        
//        print(SystemUtilites.sharedUtilities().displayBrightness(withDisplayID: currentDisplayID()))
    }
    
    func currentDisplayID() -> CGDirectDisplayID {
        let screen = NSApplication.shared.windows.first { $0.contentView is NSHostingView<EventBarView> }?.screen ?? NSScreen.main
        
        // Try get current display ID
        // if that fails, just fall back to the *main* display ID
        return (screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) ?? CGMainDisplayID()
    }
    
    func handleVolumeChange(change: EventBarKindChange) {
        switch change {
        case .increase:
            if SystemUtilites.sharedUtilities().isAudioMuted { SystemUtilites.sharedUtilities().isAudioMuted = false }
            setCurrentValueAuto(to: CGFloat(SystemUtilites.sharedUtilities().increaseVolume()))
        case .decrease:
            if SystemUtilites.sharedUtilities().isAudioMuted { SystemUtilites.sharedUtilities().isAudioMuted = false }
            setCurrentValueAuto(to: CGFloat(SystemUtilites.sharedUtilities().decreaseVolume()))
        case .muted:
            SystemUtilites.sharedUtilities().isAudioMuted.toggle()
            
            if SystemUtilites.sharedUtilities().isAudioMuted {
                self.currentValue = 0
            }
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
                SystemUtilites.sharedUtilities().setBrightnessWithDisplayID(currentDisplayID(), newValue: Float(newValue))
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
                if SystemUtilites.sharedUtilities().isAudioMuted { SystemUtilites.sharedUtilities().isAudioMuted = false }
                SystemUtilites.sharedUtilities().setVolume(Float(newValue))
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
