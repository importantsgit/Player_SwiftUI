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
    @State private var controllerDisplayState: ControllerContainerView.ControllerDisplayState = .main(.normal)
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    @State private var isLockController: Bool = false
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: UIPlayerView.PlayerState = .init()
    
    private var dragPositonY: CGFloat = 0
    
    @State private var gestureStart: Bool = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @EnvironmentObject var playerDataModel: PlayerDataModel
    
    @StateObject var systemDataModel: SystemDataModel = .init()
    
    @Binding var currentOrientation: UIInterfaceOrientation
    
    init(
        currentOrientation: Binding<UIInterfaceOrientation>) {
        self._currentOrientation = currentOrientation
    }
    
    var body: some View {
        let sensitivity = 2.0
        let isLandscape = currentOrientation.isLandscape
        let tapGesture = SpatialTapGesture()
            .onEnded { state in
                playerDataModel.showControllerSubject.send(isShowController == false)
                controllerDisplayState = isLockController ? .lock : .main(.normal)
                
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
                guard isLandscape && isLockController else { return }
                playerDataModel.showControllerSubject.send(true)
                controllerDisplayState = .main(.normal)
                
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
                playerDataModel.showControllerSubject.send(false)
            }
        
        let combineGesture = dragGesture.exclusively(
            before: tapGesture
        )
        
        ProgressView("Loading...")
            .hidden(playerDataModel.playerTimeState == .buffering || playerDataModel.isInitialized == false)
        
        PlayerView(
            player: $playerDataModel.player,
            state: $playerDataModel.state
        )
            .gesture(combineGesture)
            .overlay {
//                // MARK: if 조건문을 제거해도 뷰가 재갱신되어 State가 초기화됨
                ControllerContainerView(
                    isLockController: $isLockController,
                    controllerDisplayState: $controllerDisplayState
                )
                .environmentObject(systemDataModel)
                .hidden(isShowController == false)
                .gesture(tapGesture)
            }
            .onReadSize { viewSize = $0 }
            // Timer 로직
            .onReceive(
                playerDataModel.showControllerSubject
            ) { isShow in
                isShowController = isShow
            }
            .onReceive(
                playerDataModel.timerPublisher
            ) { _ in
                isShowController = false
                controllerDisplayState = isLockController ? .lock : .main(.normal)
            }
    }
}

#Preview {
    playerContainerView(currentOrientation: .constant(.portrait))
        .environmentObject(PlayerDataModel(url: nil))
}

