//
//  PlayerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import Combine
import SwiftUI
import UIKit
import AVFoundation
import MediaPlayer

struct playerContainerView: View {
    struct SystemValue {
        var brightness: CGFloat
        var volume: CGFloat
    }
    
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    // 컨트롤러 컨테이너를 노출 시킬 시간을 제어하는 타이머
    @State private var displayControllerTimer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    // 컨트롤러 컨테이너를 노출 시킬 동안의 카운트 값
    @State private var displayControllerCount = 0
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: UIPlayerView.PlayerState = .init()
    
    private var dragPositonY: CGFloat = 0
    
    @State private var gestureStart: Bool = false
    
    @State private var systemValue: SystemValue = .init(
        brightness: UIApplication.currentBrightness,
        volume: CGFloat(AVAudioSession.currentVolume)
    )
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @EnvironmentObject var playerDataModel: PlayerDataModel
    
    @Binding var currentOrientation: UIInterfaceOrientation
    
    init(
        displayControllerTimer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil,
        currentOrientation: Binding<UIInterfaceOrientation>) {
        self.displayControllerTimer = displayControllerTimer
        self._currentOrientation = currentOrientation
    }
    
    var body: some View {
        let isLandscape = currentOrientation.isLandscape
        let tapGesture = SpatialTapGesture()
            .onEnded { state in
                isShowController ? stopTimer() : startShowControllerTimer()
                let halfWidth = viewSize.width / 2
                
                // 왼쪽 영역 클릭
                if state.location.x < halfWidth {
                    print("Left Tapped")
                }
                // 오른쪽 영역 클릭
                else {
                    print("Right Tapped")
                }
            }
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { state in
                guard isLandscape else { return }
                
                let halfWidth = viewSize.width / 2
                            
                let changeValue = state.translation.height
                
                if state.startLocation.x < halfWidth {
                    // 밝기 조절
                    let changedBrightnessValue = changeValue / viewSize.height
                    let value = (systemValue.brightness - changedBrightnessValue)
                    UIApplication.setBrightness(value)
                }
                else {
                    // 음량 조절
                    let changedVolumeValue = changeValue / viewSize.height
                    let value = (systemValue.volume - changedVolumeValue)
                    MPVolumeView().setVolume(volume: Float(value))
                }
            }
            .onEnded { state in
                guard isLandscape else { return }
                
                let halfWidth = viewSize.width / 2
                if state.startLocation.x < halfWidth {
                    systemValue.brightness = UIApplication.currentBrightness
                }
                else {
                    systemValue.volume = CGFloat(AVAudioSession.currentVolume)
                }
                
            }
        ProgressView("Loading...")
            .hidden(playerDataModel.playerTimeState == .buffering || playerDataModel.isInitialized == false)
        
        PlayerView(
            player: $playerDataModel.player,
            state: $playerDataModel.state
        )
            .gesture(tapGesture
                .simultaneously(
                    with: dragGesture
                )
            )
            .overlay {
//                // MARK: if 조건문을 제거해도 뷰가 재갱신되어 State가 초기화됨
                ControllerContainerView(
                    displayControllerCount: $displayControllerCount
                )
                .hidden(isShowController == false)
                .gesture(tapGesture)
            }
            .onReadSize { viewSize = $0 }
            .onAppear {
            }
    }
    
    func startShowControllerTimer() {
        if displayControllerTimer != nil {
            displayControllerCount = 0
            return
        }
        
        displayControllerTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowController = true
        }
        displayControllerCount = 0
        
        displayControllerTimer?.sink { timer in
            displayControllerCount += 1
            
            if displayControllerCount >= 5 {
                stopTimer()
            }
        }
        .store(in: &cancellables)
    }
    
    func stopTimer() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowController = false
        } completion: {
            displayControllerTimer?.upstream.connect().cancel()
            displayControllerTimer = nil
        }
    }
    
    func setBrightness(value: CGFloat) {
        UIApplication.currentWindow?.windowScene?.screen.brightness = value
    }
    
    func setVolume(value: Float) {
        
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

#Preview {
    playerContainerView(currentOrientation: .constant(.portrait))
        .environmentObject(PlayerDataModel(url: nil))
}

