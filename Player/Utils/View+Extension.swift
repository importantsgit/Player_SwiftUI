//
//  View+Extension.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI

extension View {
    
    // MARK: 외부로 크기 데이터를 전달하는 메서드
    @ViewBuilder
    func onReadSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        self.customBackground {
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
    
    @ViewBuilder
    func customBackground<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        self.background(alignment: alignment, content: content)
    }
}

// MARK: PreferenceKey를 따르는 값은 뷰 계층 내에서 값을 공유 가능
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}
