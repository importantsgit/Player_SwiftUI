//
//  OtherControllerView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI

struct OtherControllerView: View {
    @Binding var displayControllerCount: Int
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(title)
                    .foregroundStyle(.white)
                Spacer()
            }
            Spacer()
        }
        .background(.black.opacity(0.3))
    }
}
