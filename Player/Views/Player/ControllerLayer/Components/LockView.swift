//
//  LockView.swift
//  Player
//
//  Created by Importants on 10/22/24.
//

import SwiftUI

struct LockView: View {
    @Binding var isLockController: Bool
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 32)
            HStack {
                Spacer()
                Button {
                    isLockController = false
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
}

#Preview {
    LockView(isLockController: .constant(true))
        .background(.black.opacity(0.3))
}
