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
        currentScene?.interfaceOrientation ?? .portrait
    }
    
    static var currentWindow: UIWindow? {
        currentScene?.windows.first(where: { $0.isKeyWindow })
    }
}


