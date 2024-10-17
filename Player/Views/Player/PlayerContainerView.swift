//
//  PlayerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import Combine
import SwiftUI
import UIKit

struct playerContainerView: View {
    // 컨트롤러 컨테이너를 노출 시킬지 여부
    @State private var isShowController: Bool = false
    // 컨트롤러 컨테이너를 노출 시킬 시간을 제어하는 타이머
    @State private var displayControllerTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
    // 컨트롤러 컨테이너를 노출 시킬 동안의 카운트 값
    @State private var displayControllerCount = 0
    
    @State private var viewSize: CGSize = .zero
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        let tap = SpatialTapGesture()
            .onEnded { state in
                isShowController ? stopTimer() : startShowControllerTimer()
                let widthHelfSize = viewSize.width / 2
                
                
                // 왼쪽 영역 클릭
                if widthHelfSize > state.location.x {
                    print("Left Tapped")
                }
                // 오른쪽 영역 클릭
                else {
                    print("Right Tapped")
                }
            }
        
        PlayerView()
            .gesture(tap)
            .overlay {
                if isShowController {
                    ControllerContainerView(
                        displayControllerCount: $displayControllerCount
                    )
                    .id("ControllerContainerView")
                    .gesture(tap)
                }

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
            print(displayControllerCount)
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


final class PlayerControllerFeature {
    struct State {
        var playState: PlayState
        var playerState: PlayerState
    }
    
    @Published var state: State
    
    init(state: State) {
        self.state = state
    }
}

enum PlayState {
    case play
    case pause
    case end
}

enum PlayerState {
    case idle
    case Playing
    case stop
}

#Preview {
    playerContainerView()
}
