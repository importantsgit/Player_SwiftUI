//
//  UIApplication+Extension.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import UIKit

extension UIApplication {
    private static var currentScene: UIWindowScene? {
        shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
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
}


