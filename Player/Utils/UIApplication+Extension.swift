//
//  UIApplication+Extension.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import UIKit

extension UIApplication {
    private static var currentScene: UIWindowScene? {
        shared.connectedScenes.first as? UIWindowScene
        // 단일 WindowScene이면서 active 아닌 상태에서 값을 불러오는 경우가 있다면 위 로직을 사용
            // .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
    
    static var orientation: UIInterfaceOrientation {
        let current = currentScene?.interfaceOrientation ??
        // 만약 값이 nil이라면 화면 정보 값을 이용
        (UIDevice.current.orientation.isLandscape ? .landscapeLeft : .portrait)
        
        return current
    }
    
    static var currentWindow: UIWindow? {
        currentScene?.windows.first(where: { $0.isKeyWindow })
    }
    
    static var currentWindowSize: CGRect? {
        currentWindow?.frame
    }
    
    static var safeAreaInset: UIEdgeInsets? {
        currentWindow?.safeAreaInsets ?? .init(top: 40, left: 40, bottom: 40, right: 40)
    }
}


