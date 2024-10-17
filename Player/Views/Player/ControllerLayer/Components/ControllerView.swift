//
//  ControllerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI


struct ControllerView: View {
    @Binding var displayControllerCount: Int
    @Binding var controllerState: ControllerContainerView.ControllerState
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("ControllerContainerView")
                    .foregroundStyle(.white)
                Spacer()
            }
            Spacer()
            HStack {
                Button {
                    displayControllerCount = 0
                    controllerState.showOneControllerView()
                } label: {
                    Text("one")
                        .frame(
                            width: 100,
                            height: 48
                        )
                }
                
                Button {
                    displayControllerCount = 0
                    controllerState.showTwoControllerView()
                } label: {
                    Text("two")
                        .frame(
                            width: 100,
                            height: 48
                        )
                }
            }
            Spacer()
        }
        .background(.black.opacity(0.3))
    }
}

