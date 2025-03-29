//
//  BackgroundView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct BackgroundView: View {
    let starCount = 60
    private let nightSkyColor = Color("nightSky")
    private let cloudColor = Color("cloud")
    
    @State private var starPositions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [nightSkyColor, .cloud]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [.gray.opacity(0.9), nightSkyColor]),
                    startPoint: .trailing,
                    endPoint: .leading
                )
                .blendMode(.lighten)
                .blur(radius: 90)
                .ignoresSafeArea()
                
                ForEach(0..<starCount, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: 2)
                        .position(
                            x: starPositions[safe: index]?.x ?? 0,
                            y: starPositions[safe: index]?.y ?? 0
                        )
                }
            }
            .onAppear {
                if starPositions.isEmpty {
                    starPositions = (0..<starCount).map { _ in
                        CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                    }
                }
            }
        }
    }
}

// Array safe subscript helper
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
