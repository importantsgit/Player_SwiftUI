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
    enum ControllerDisplayState {
        case main(MainDisplayState)
        case lock
        
        enum MainDisplayState {
            case normal
            case system
            case other
        }
    }
    
    @Binding var isLockController: Bool
    @Binding var controllerDisplayState: ControllerDisplayState
    @EnvironmentObject var systemDataModel: SystemDataModel
    @State private var cancellables = Set<AnyCancellable>()
    
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
        switch controllerDisplayState {
        case let .main(state):
            switch state {
            case .normal:
                ControllerView(
                    isLockController: $isLockController,
                    controllerDisplayState: $controllerDisplayState
                )
            case .system:
                SystemDisplayView()
            case .other:
                OtherControllerView(title: "two")
            }
        case .lock:
            LockView(isLockController: $isLockController)
        }
    }
}
