//
//  WatermarkView.swift
//  Player
//
//  Created by 이재훈 on 11/6/24.
//

import SwiftUI

struct CustomWatermark: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                context.opacity = 0.3
                let text = "Watermark"
                let font = Font.system(size: 36).weight(.bold)
                
                for row in stride(from: -size.height, through: size.height, by: 100) {
                    for column in stride(from: -size.width, through: size.width, by: 200) {
                        let position = CGPoint(x: column, y: row)
                        context.draw(Text(text).font(font), at: position)
                    }
                }
            }
        }
    }
}
