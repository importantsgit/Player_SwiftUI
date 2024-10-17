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

struct playerContainerView: View {
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    // 컨트롤러 컨테이너를 노출 시킬 시간을 제어하는 타이머
    @State private var displayControllerTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
    // 컨트롤러 컨테이너를 노출 시킬 동안의 카운트 값
    @State private var displayControllerCount = 0
    
    @State private var viewSize: CGSize = .zero
    
    @State private var playerState: AVPlayerView.PlayerState = .init()
    
    private var dragPositonY: CGFloat = 0
    
    @EnvironmentObject var playerDataModel: PlayerDataModel
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        let tapGesture = SpatialTapGesture()
            .onEnded { state in
                isShowController ? stopTimer() : startShowControllerTimer()
                let halfWidth = viewSize.width / 2
                
                
                // 왼쪽 영역 클릭
                if state.location.x < halfWidth {
                    print("Left Tapped")
                    playerDataModel.player?.play()
                }
                // 오른쪽 영역 클릭
                else {
                    print("Right Tapped")
                    playerDataModel.player?.pause()
                }
            }
        let dragGesture = DragGesture()
            .onChanged { state in
                let halfWidth = viewSize.width / 2
                
                // 왼쪽
                let changeValue = state.translation.height
                if state.startLocation.x < halfWidth {
                    print(changeValue)
                }
                else {
                    print(changeValue)
                }
            }
            .onEnded { state in
                print(state.velocity)
            }
        PlayerView(
            player: $playerDataModel.player,
            state: $playerDataModel.state
        )
            .gesture(tapGesture
                .exclusively(
                    before: dragGesture
                )
            )
            .overlay {
                // MARK: if 조건문을 제거해도 뷰가 재갱신되어 State가 초기화됨
                ControllerContainerView(
                    displayControllerCount: $displayControllerCount
                )
                .hidden(isShowController == false)
                .gesture(tapGesture)
            }
            .onReadSize { viewSize = $0 }
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
}

#Preview {
    playerContainerView()
        .environmentObject(PlayerDataModel(url: nil))
}

