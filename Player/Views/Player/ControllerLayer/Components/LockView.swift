//
//  LockView.swift
//  Player
//
//  Created by Importants on 10/22/24.
//

import SwiftUI

struct LockView: View {
    enum ControllerViewAction {
        case unlockButtonTapped
    }
    
    @EnvironmentObject var playerManager: PlayerManager
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 32)
            HStack {
                Spacer()
                Button {
                    handleAction(.unlockButtonTapped)
                } label: {
                    Text("잠금해제")
                        .foregroundStyle(.white)
                        .frame(width: 108, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(.capsule)
                        
                }
                Spacer()
                    .frame(width: 16)
            }
            Spacer()
        }
    }
    
    func handleAction(_ action: ControllerViewAction) {
        switch action {
        case .unlockButtonTapped:
            playerManager.handleAction(.unlockButtonTapped)
        }
    }
}

#Preview {
    LockView()
        .background(.black.opacity(0.3))
}
