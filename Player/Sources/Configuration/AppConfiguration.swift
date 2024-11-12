//
//  AppConfiguration.swift
//  Player
//
//  Created by 이재훈 on 11/12/24.
//

import Foundation

enum BuildTarget: CustomStringConvertible {
    case release
    case stage
    case development
    
    var description: String {
        switch self {
        case .release: return "release"
        case .development: return "development"
        case .stage: return "stage"
        }
    }
}

struct BuildConfiguration {
    static let target: BuildTarget = {
#if BUILD_FOR_RELEASE
        return .release
#elseif BUILD_FOR_STAGE
        return .stage
#else
        return .development
#endif
    }()
}
