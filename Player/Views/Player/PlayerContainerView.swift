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
    @EnvironmentObject var playerManager: PlayerManager
    
    @StateObject var systemDataModel: SystemDataModel = .init()
    
    @State private var containerDisplayState: ContainerDisplayState = .normal
    @State private var controllerDisplayState: ControllerContainerView.ControllerDisplayState = .main(.normal)
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: PlayerManager.PlayerState = .init(videoQuality: .low)
    
    @State private var gestureStart: Bool = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @Binding var currentOrientation: UIInterfaceOrientation
    
    init(
        currentOrientation: Binding<UIInterfaceOrientation>
    ) {
        self._currentOrientation = currentOrientation
    }
    
    var body: some View {
        let sensitivity = 2.0
        let isLandscape = currentOrientation.isLandscape
        let tapGesture = SpatialTapGesture()
            .onEnded { state in
                playerManager.showControllerSubject.send(isShowController == false)
                
                
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
        let dragGesture = DragGesture(minimumDistance: 1)
            .onChanged { state in
                print("dragGesture")
                guard isLandscape && controllerDisplayState.isMain
                else { return }

                guard let currentWindowSize = UIApplication.currentWindowSize,
                      (currentWindowSize.minY + 40)...(currentWindowSize.maxY - 40) ~= state.startLocation.y
                else { return }
                    
                playerManager.showControllerSubject.send(true)
                controllerDisplayState = .main(.system)
                
                let halfWidth = viewSize.width / 2
                let changeValue = state.translation.height
                
                if state.startLocation.x < halfWidth {
                    // 밝기 조절
                    let changedBrightnessValue = (changeValue / viewSize.height) * sensitivity
                    let value = (systemDataModel.brightnessValue.origin - changedBrightnessValue)
                    systemDataModel.setBrightness(
                        value: value
                    )
                }
                else {
                    // 음량 조절
                    let changedVolumeValue = (changeValue / viewSize.height) * sensitivity
                    let value = (systemDataModel.volumeValue.origin - Float(changedVolumeValue))
                    systemDataModel.setVolume(
                        value: value
                    )
                }
            }
            .onEnded { state in
                guard isLandscape else { return }
                
                let halfWidth = viewSize.width / 2
                if state.startLocation.x < halfWidth {
                    systemDataModel.brightnessValue.origin = systemDataModel.brightnessValue.changed
                }
                else {
                    systemDataModel.volumeValue.origin = systemDataModel.volumeValue.changed
                }
                playerManager.showControllerSubject.send(false)
            }
        let combineGesture = dragGesture.exclusively(
            before: tapGesture
        )
        ZStack {
            HStack(spacing: 0) {
                PlayerView()
                    .gesture(combineGesture)
                    .overlay {
                        ZStack {
                            ControllerContainerView(
                                controllerDisplayState: $controllerDisplayState,
                                currentOrientation: $currentOrientation
                            )
                            .environmentObject(systemDataModel)
                            .hidden(isShowController == false)
                            .gesture(tapGesture)
                        }
                    }
                    .onReadSize { viewSize = $0 }
                    // Timer 로직
                    .onReceive(
                        playerManager.showControllerSubject
                    ) { isShow in
                        isShowController = isShow
                        
                        if isShow == false && controllerDisplayState.isMain {
                            controllerDisplayState = .main(.normal)
                        }
                    }
                    .onReceive(
                        playerManager.timerPublisher
                    ) { _ in
                        // showControllerSubject.send(true)인 경우만 receive
                        // 5초 후 플레이어를 닫기 위해
                        isShowController = false
                        
                        if controllerDisplayState.isMain {
                            controllerDisplayState = .main(.normal)
                        }
                    }
                
                SettingView()
                    .frame(width: 200)
                    .hidden(containerDisplayState != .setting && isLandscape == false)
                
            }
            .animation(.easeInOut(duration: 0.2), value: isShowController)

                //
            
            AudioModeView(
                controllerDisplayState: $controllerDisplayState,
                currentOrientation: $currentOrientation
            )
                .hidden(controllerDisplayState != .audio)
            
            ProgressView("Loading...")
                .progressViewStyle(.circular)
                .scaleEffect(2)
                .tint(.white)
                .hidden(
                    playerManager.playerTimeState != .buffering ||
                    playerManager.isInitialized
                )
        }
    }
}

#Preview {
    playerContainerView(currentOrientation: .constant(.portrait))
        .environmentObject(PlayerManager())
}

