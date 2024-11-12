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
    enum Sensitivity {
        static let system = 2.0
        static let seeking = 0.1
    }
    
    enum DragDirection {
        case vertical
        case horizontal
        case normal
    }
    
    enum ContainerViewAction {
        case microSeekingDragging(CGFloat)
        case microSeekingDragged
        case systemDragging
        case systemDragged
        case gestureConflicted
        
        case controllerTapped
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    
    @StateObject var systemDataModel: SystemDataModel = .init()
    
    @State private var dragDirection: DragDirection = .normal
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: PlayerManager.PlayerState = .init(videoQuality: .low)
    
    @GestureState var seekGesture: Bool = true
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @Binding var currentOrientation: UIInterfaceOrientation
    
    init(
        currentOrientation: Binding<UIInterfaceOrientation>
    ) {
        self._currentOrientation = currentOrientation
    }
    
    var body: some View {
        let isLandscape = currentOrientation.isLandscape
        let tapGesture = SpatialTapGesture()
            .onEnded { state in
                guard playerManager.containerDisplayState == .normal
                else {
                    playerManager.containerDisplayState = .normal
                    return
                }
                
                handleAction(.controllerTapped)
                
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
            .updating($seekGesture) { currentState, state, transition in
                state = currentState.translation == .zero ? true : false
            }
            .onChanged { state in
                guard isLandscape,
                      playerManager.containerDisplayState == .normal
                else { return }
                
                guard let safeAreaInset = UIApplication.safeAreaInset,
                      let currentWindowSize = UIApplication.currentWindowSize,
                      (safeAreaInset.top)...(currentWindowSize.maxY - safeAreaInset.bottom) ~= state.startLocation.y
                else { return }

                switch dragDirection {
                case .vertical:
                    handleAction(.systemDragging)
                    
                    let halfWidth = viewSize.width / 2
                    let value = state.translation.height
                    let changedValue = (value / viewSize.height) * Sensitivity.system
                    
                    if state.startLocation.x < halfWidth {
                        // 밝기 조절
                        let updateValue = (systemDataModel.brightnessValue.origin - changedValue)
                        systemDataModel.handleAction(.updateBrightness(updateValue))
                    }
                    else {
                        // 음량 조절
                        let updateValue = (systemDataModel.volumeValue.origin - Float(changedValue))
                        systemDataModel.handleAction(.updateVolume(updateValue))
                    }
                    
                case .horizontal:
                    let changeValue = state.translation.width / viewSize.width * Sensitivity.seeking
                    handleAction(.microSeekingDragging(changeValue))
                    
                case .normal:
                    // 드래그 방향 init (수직: 시스템 / 수평: micro seek)
                    let transitionX = abs(state.translation.width)
                    let transitionY = abs(state.translation.height)
                    if transitionX >= 1 || transitionY >= 1 {
                        dragDirection = transitionX > transitionY ? .horizontal : .vertical
                        print(dragDirection)
                    }
                }
            }
            .onEnded { state in
                guard isLandscape else { return }
                switch dragDirection {
                case .horizontal:
                    handleAction(.microSeekingDragged)
                case .vertical:
                    let halfWidth = viewSize.width / 2
                    
                    if state.startLocation.x < halfWidth {
                        systemDataModel.brightnessValue.origin = systemDataModel.brightnessValue.changed
                    }
                    else {
                        systemDataModel.volumeValue.origin = systemDataModel.volumeValue.changed
                    }
                    handleAction(.systemDragged)
                    
                default:
                    break
                }
                
                dragDirection = .normal
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
                            ControllerContainerView(currentOrientation: $currentOrientation)
                                .environmentObject(systemDataModel)
                                .hidden(playerManager.controllerDisplayState == .hidden)
                                .onChange(of: seekGesture) { (_, seekGesture) in
                                    if seekGesture == true {
                                        handleAction(.gestureConflicted)
                                    }
                                }
                                .gesture(tapGesture)
                        }
                    }
            }
            
            AudioModeView(currentOrientation: $currentOrientation)
                .hidden(playerManager.containerDisplayState != .audio)
            
            HStack(spacing: 0) {
                Spacer()
                SettingView()
                    .frame(width: 380)
            }
            .hidden(playerManager.containerDisplayState != .setting || isLandscape == false)
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(.white)
                .hidden(
                    playerManager.playerTimeState != .buffering ||
                    playerManager.isInitialized
                )
        }
        .onReadSize { viewSize = $0 }
        // MARK: - Timer 로직
        // hidden 아닌 경우만 5초 뒤 isShowController = .hidden
        .onReceive(
            playerManager.$controllerDisplayState
                .filter { $0 != .hidden }
                .map { _ in () }
                .debounce(for: .seconds(5), scheduler: RunLoop.main)
        ) { _ in
            playerManager.controllerDisplayState = .hidden
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIScreen.capturedDidChangeNotification)
        ) { isCaptured in
            print("isCaptured: \(isCaptured)")
        }
    }
    
    func handleAction(_ action: ContainerViewAction) {
        switch action {
        case .controllerTapped:
            playerManager.handleAction(.controllerTapped)
            
        case .gestureConflicted:
            playerManager.handleAction(.resetGestureValue)
            systemDataModel.brightnessValue.origin = systemDataModel.brightnessValue.changed
            systemDataModel.volumeValue.origin = systemDataModel.volumeValue.changed
            
        case let .microSeekingDragging(transition):
            playerManager.handleAction(.microSeekingDragging(transition))
            
        case .microSeekingDragged:
            playerManager.handleAction(.microSeekingDragged)
            
        case .systemDragging:
            playerManager.handleAction(.systemDragging)
            
        case .systemDragged:
            playerManager.handleAction(.systemDragged)
        }
    }
}

#Preview {
    playerContainerView(currentOrientation: .constant(.portrait))
        .environmentObject(PlayerManager())
}

