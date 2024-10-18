//
//  View+Extension.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import MediaPlayer

extension View {
    @ViewBuilder
    func detectOrientetion(_ orientation: Binding<UIInterfaceOrientation>) -> some View {
        modifier(OrientationInfo(orientation: orientation))
    }
    
    @ViewBuilder
    func hideSystemVolumeView(isHidden: Bool) -> some View {
        self.modifier(VolumeViewModifier(isHidden: isHidden))
    }
    
    // MARK: - hidden 처리 메서드
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
    
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

// MARK: - ViewModifier

struct VolumeView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView.view
        volumeView.alpha = 0.001
        volumeView.showsVolumeSlider = true
        return volumeView
    }
    func updateUIView(_ uiView: MPVolumeView, context: Context) { }
}

struct VolumeViewModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        ZStack {
            if !isHidden {
                VolumeView()
                    .frame(width: 0, height: 0)
            }
            content
        }
    }
}

struct OrientationInfo: ViewModifier {
    @Binding var orientation: UIInterfaceOrientation
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIApplication.orientation
            }
    }
}

extension UIInterfaceOrientation {
    var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }
}
