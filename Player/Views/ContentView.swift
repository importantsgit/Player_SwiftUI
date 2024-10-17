//
//  ContentView.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var currentOrientation = UIApplication.orientation
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        // 자동으로 Spacing이 들어가기 때문에 0을 입력
        VStack(spacing: 0) {
            if currentOrientation == .portrait {
                NavigationController(title: "Video")
            }
            
            playerContainerView()
                .frame(height: viewSize.width/1.5)
            
            if currentOrientation == .portrait {
                ContentDetailView()
            }
        }
        .onReadSize {
            print($0)
            viewSize = $0
        }
    }
}

struct NavigationController: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 48, height: 48)
            }
            Spacer()
            Text(title)
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 48, height: 48)
            }
        }
        .frame(height: 48)
        
    }
}

struct ContentDetailView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
            }
            Spacer()
        }
        .background(.gray)
    }
}

#Preview {
    ContentView()
}
