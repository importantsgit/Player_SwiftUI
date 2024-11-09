//
//  File.swift
//  Player
//
//  Created by Importants on 10/20/24.
//

import Combine
import MediaPlayer

final class SystemDataModel: ObservableObject {
    struct BrightnessValue {
        var origin: CGFloat
        var changed: CGFloat
    }
    
    struct VolumeValue {
        var origin: Float
        var changed: Float
    }
    
    @Published var brightnessValue: BrightnessValue = .init(
        origin: UIApplication.currentBrightness,
        changed: UIApplication.currentBrightness
    )
    
    @Published var volumeValue: VolumeValue = .init(
        origin: AVAudioSession.currentVolume,
        changed: AVAudioSession.currentVolume
    )
    
    enum SystemViewAction {
        case updateBrightness(CGFloat)
        case updateVolume(Float)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func handleAction(_ action: SystemViewAction) {
        switch action {
        case let .updateBrightness(value):
            setBrightness(value: value)
            
        case let .updateVolume(value):
            setVolume(value: value)
        }
    }
}

private extension SystemDataModel {
    func setBrightness(value: CGFloat) {
        let currentValue = reduceValue(value: value)
        brightnessValue.changed = currentValue
        UIApplication.setBrightness(currentValue)
    }
    
    func setVolume(value: Float) {
        let currentValue = reduceValue(value: value)
        volumeValue.changed = currentValue
        MPVolumeView.view.setVolume(
            volume: currentValue
        )
    }
    
    func reduceValue<T: Comparable & FloatingPoint>(value: T) -> T {
        min(max(value, 0), 1)
    }
}

extension UIApplication {
    // 값 반환
    static var currentBrightness: CGFloat {
        UIApplication.currentWindow?.windowScene?.screen.brightness ?? 0.5
    }
    
    // 값 설정
    static func setBrightness(_ value: CGFloat) {
        UIApplication.currentWindow?.windowScene?.screen.brightness = value
    }
}

extension MPVolumeView {
    static let view = MPVolumeView()
    
    func setVolume(volume: Float) {
        guard let slider = MPVolumeView.view.subviews.first(where: { $0 is UISlider }) as? UISlider
        else { return }
        slider.value = volume
    }
}

extension AVAudioSession {
    static var currentVolume: Float {
        AVAudioSession.sharedInstance().outputVolume
    }
}
