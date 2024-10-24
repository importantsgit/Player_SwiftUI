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
    
    @EnvironmentObject var playerDataModel: PlayerDataModel
    
    @StateObject var systemDataModel: SystemDataModel = .init()
    
    @State private var controllerDisplayState: ControllerContainerView.ControllerDisplayState = .main(.normal)
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: UIPlayerView.PlayerState = .init()
    
    @State private var gestureStart: Bool = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
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
                playerDataModel.showControllerSubject.send(true)
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
                // MARK: if 조건문을 제거해도 뷰가 재갱신되어 State가 초기화됨
                ControllerContainerView(
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
                
                if isShow == false && controllerDisplayState.isMain {
                    // FIXME: isShow가 false가 되는 순간에 기본 컨트롤러 UI로 바뀌는데, 애니메이션이 0.2초가 걸려 기본 컨트롤러 UI가 살짝 보이는 이슈 발생
                    controllerDisplayState = .main(.normal)
                }
            }
            .onReceive(
                playerDataModel.timerPublisher
            ) { _ in
                // showControllerSubject.send(true)인 경우만 receive
                // 5초 후 플레이어를 닫기 위해
                isShowController = false
                
                if controllerDisplayState.isMain {
                    controllerDisplayState = .main(.normal)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isShowController)
        
        if controllerDisplayState == .audio {
            AudioModeView(controllerDisplayState: $controllerDisplayState)
        }
    }
}

#Preview {
    playerContainerView(currentOrientation: .constant(.portrait))
        .environmentObject(PlayerDataModel(url: nil))
}

