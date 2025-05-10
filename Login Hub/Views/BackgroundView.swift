//
//  BackgroundView.swift
//  Login Hub
//
//  Created by Sabir Alizada on 22.03.25.
//

import SwiftUI

struct BackgroundView: View {
    @State private var starPositions: [CGPoint] = []
    private static let starCount = 60
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                baseGradient
                overlayGlare
                starsView(in: geometry.size)
            }
            // Initializes stars once when the view appears
            .task {
                if starPositions.isEmpty {
                    starPositions = generateStars(in: geometry.size)
                }
            }
        }
    }
    
    // MARK: - Gradients
    /// The base night sky gradient
    private var baseGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.nightSky, .cloud]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .ignoresSafeArea()
    }

    /// Overlay glare effect for depth
    private var overlayGlare: some View {
        LinearGradient(
            gradient: Gradient(colors: [.gray.opacity(0.9), .nightSky]),
            startPoint: .trailing,
            endPoint: .leading
        )
        .blendMode(.lighten)
        .blur(radius: 90)
        .ignoresSafeArea()
    }

    // MARK: - Stars Rendering
    /// Renders the star circles at their positions
    private func starsView(in size: CGSize) -> some View {
        ForEach(0..<BackgroundView.starCount, id: \.self) { index in
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 2, height: 2)
                .position(starPositions[safe: index] ?? .zero)
        }
    }

    // MARK: - Stars Generation
    /// Generates random star positions within the given size
    private func generateStars(in size: CGSize) -> [CGPoint] {
        (0..<BackgroundView.starCount).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
        }
    }
}

// Array safe subscript helper
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
