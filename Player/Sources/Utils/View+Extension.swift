//
//  View+Extension.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import MediaPlayer

extension View {
    /**
     화면의 회전을 감지하기 위한 ViewBuilder Method
     
     - Parameter orientation:현재 회전 방향을 저장할 바인딩 변수
     */
    @ViewBuilder
    func detectOrientation(
        _ orientation: Binding<UIInterfaceOrientation>
    ) -> some View {
        modifier(
            OrientationInfo(orientation: orientation)
        )
    }
    
    /**
     시스템 볼륨을 노출 시키지 않게 하는 ViewBuilder Method
     
     - Parameter isHidden: 시스템 볼륨 뷰를 숨길지 여부를 결정하는 Bool 값.
                           true일 경우 시스템 볼륨 뷰가 숨겨지고, false일 경우 표시됩니다.
        
     - Note: 이 메서드는 MPVolumeView를 사용하여 시스템 볼륨 뷰를 제어합니다.
             앱의 특정 부분에서만 시스템 볼륨 뷰를 숨기고 싶을 때 사용하면 됩니다.
     */
    @ViewBuilder
    func hideSystemVolumeView(
        isHidden: Bool
    ) -> some View {
        self.modifier(
            VolumeViewModifier(
                isHidden: isHidden
            )
        )
    }
    
    /**
     View의 노출 여부를 지정하는 ViewBuilder Method
     
    Important: 해당 메서드를 사용 시, 뷰가 재생성되는 이슈가 있으니 주의해서 사용할 것
     */
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
    
    // MARK: - Size Reporting
    @ViewBuilder
    func onReadSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }
}

// MARK: - Preference Key for Size
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

// MARK: - Volume View
struct VolumeView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()
        volumeView.alpha = 0.001
        volumeView.showsVolumeSlider = true
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) { }
}

// MARK: - View Modifiers
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var orientation: UIInterfaceOrientation
    
    func body(content: Content) -> some View {
        content
            .onChange(
                of: horizontalSizeClass
            ) { _, newValue in
                print("orientationLock: \(AppDelegate.orientationLock)")
                guard orientation != UIApplication.orientation,
                      AppDelegate.orientationLock.matches(to: orientation)
                else { return }
                
                orientation = UIApplication.orientation
            }
            .onReceive(NotificationCenter
                .default
                .publisher(
                    for: UIDevice.orientationDidChangeNotification
                )
            ) { _ in
                print("orientationLock: \(AppDelegate.orientationLock)")
                guard orientation != UIApplication.orientation,
                      AppDelegate.orientationLock.matches(to: orientation)
                else { return }
                
                orientation = UIApplication.orientation
            }

    }
}

// MARK: - Helper Extensions
extension UIInterfaceOrientation {
    var isLandscape: Bool {
        self == .landscapeLeft || self == .landscapeRight
    }
}


extension Image {
    @ViewBuilder
    func styled(size: CGFloat, tintColor: Color) -> some View {
        self
            .resizable()
            .frame(width: size, height: size)
            .foregroundColor(tintColor)
    }
}

