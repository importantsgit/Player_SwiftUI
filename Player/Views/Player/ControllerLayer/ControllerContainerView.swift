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
    struct ControllerState {
        var isDisplayMainView: Bool
        var isDisplayOneView: Bool
        var isDisplayTwoView: Bool
        
        init(
            isDisplayMainView: Bool = true,
            isDisplayOneView: Bool = false,
            isDisplayTwoView: Bool = false
        ) {
            self.isDisplayMainView = isDisplayMainView
            self.isDisplayOneView = isDisplayOneView
            self.isDisplayTwoView = isDisplayTwoView
        }
    }
    @Binding var displayControllerCount: Int
    @State private var controllerState: ControllerState = .init()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        Group {
            if controllerState.isDisplayMainView {
                ControllerView(
                    displayControllerCount: $displayControllerCount,
                    controllerState: $controllerState
                )
            }
            else if controllerState.isDisplayOneView {
                OtherControllerView(displayControllerCount: $displayControllerCount, title: "one")
            }
            else if controllerState.isDisplayTwoView {
                OtherControllerView(displayControllerCount: $displayControllerCount, title: "two")
            }
            else {
                EmptyView()
            }
        }
    }
}

extension ControllerContainerView.ControllerState {
    mutating func showMainControllerView() {
        self.isDisplayMainView = true
        self.isDisplayOneView = false
        self.isDisplayTwoView = false
    }
    
    mutating func showOneControllerView() {
        self.isDisplayMainView = false
        self.isDisplayOneView = true
        self.isDisplayTwoView = false
    }
    
    mutating func showTwoControllerView() {
        self.isDisplayMainView = false
        self.isDisplayOneView = false
        self.isDisplayTwoView = true
    }
}
