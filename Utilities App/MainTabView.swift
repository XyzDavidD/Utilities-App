//
//  MainTabView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct MainTabView: View {
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var body: some View {
        TabView {
            CalculatorView()
                .tabItem {
                    Image(systemName: "function")
                    Text("Calculator")
                }
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
            
            TodoView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("To-Do")
                }
            
            UnitConverterView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Converter")
                }
        }
        .accentColor(primaryBlue)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Add subtle shadow
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
        
        // Selected item styling with premium blue
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(primaryBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(primaryBlue),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Normal item styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray3
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray2,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
