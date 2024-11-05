//
//  ControllerContainerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import AVFAudio
import Combine

struct ControllerContainerView: View {
    @EnvironmentObject var systemDataModel: SystemDataModel
    @EnvironmentObject var playerManager: PlayerManager
    @State private var cancellables = Set<AnyCancellable>()
    @Binding var currentOrientation: UIInterfaceOrientation
    
    var body: some View {
        ZStack {
            content
                .background(
                    Color
                        .black
                        .opacity(0.3)
                        .allowsHitTesting(false)
                    // allowsHitTesting을 사용하기 위해서 Color 타입을 명시적으로 입력
                )
        }
    }
    
    // MARK: - ViewBuilder을 입력시 다양한 타입의 뷰를 반환하거나 여러 개의 뷰를 반환할 수 있다.
    @ViewBuilder
    private var content: some View {
        switch playerManager.controllerDisplayState {
        case .normal:
            ControllerView(currentOrientation: $currentOrientation)
        case .system:
            SystemDisplayView()
        case .lock:
            LockView()
        }
    }
}

