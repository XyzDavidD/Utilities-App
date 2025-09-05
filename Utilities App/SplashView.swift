//
//  SplashView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var buttonScale: CGFloat = 0.8
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var body: some View {
        if showMainApp {
            MainTabView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        } else {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 50) {
                    Spacer()
                    
                    // Premium logo design
                    VStack(spacing: 30) {
                        ZStack {
                            // Outer ring with gradient
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [primaryBlue, accentGreen],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(logoScale)
                                .opacity(logoOpacity)
                            
                            // Inner background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [primaryBlue.opacity(0.1), accentGreen.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 85, height: 85)
                                .scaleEffect(logoScale)
                                .opacity(logoOpacity)
                            
                            // Icon / App Logo
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .scaleEffect(logoScale)
                                .opacity(logoOpacity)
                        }
                        
                        VStack(spacing: 12) {
                            Text("UtilityKit")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .offset(y: textOffset)
                                .opacity(logoOpacity)
                            
                            Text("Professional utility suite")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .offset(y: textOffset)
                                .opacity(logoOpacity)
                        }
                    }
                    
                    Spacer()
                    
                    // Premium button design
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showMainApp = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [primaryBlue, accentGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(buttonScale)
                    .opacity(logoOpacity)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    textOffset = 0
                }
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
                    buttonScale = 1.0
                }
            }
        }
    }
}

// Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SplashView()
}
