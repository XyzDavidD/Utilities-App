//
//  UnitConverterView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

enum ConversionCategory: String, CaseIterable {
    case length = "Length"
    case weight = "Weight"
    case temperature = "Temperature"
    case volume = "Volume"
    
    var icon: String {
        switch self {
        case .length: return "ruler"
        case .weight: return "scalemass"
        case .temperature: return "thermometer"
        case .volume: return "drop"
        }
    }
    
    var color: Color {
        switch self {
        case .length: return Color(hex: "#53AAEA")        // Blue
        case .weight: return Color(hex: "#66D9A7")        // Green  
        case .temperature: return Color(hex: "#FF6B6B")   // Red
        case .volume: return Color(hex: "#4ECDC4")        // Teal
        }
    }
}

struct UnitConverterView: View {
    @State private var selectedCategory: ConversionCategory = .length
    @State private var inputValue: String = ""
    @State private var fromUnit: String = ""
    @State private var toUnit: String = ""
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var availableUnits: [String] {
        switch selectedCategory {
        case .length:
            return ["Meters", "Kilometers", "Centimeters", "Millimeters", "Inches", "Feet", "Yards", "Miles"]
        case .weight:
            return ["Kilograms", "Grams", "Pounds", "Ounces", "Tons", "Stones"]
        case .temperature:
            return ["Celsius", "Fahrenheit", "Kelvin"]
        case .volume:
            return ["Liters", "Milliliters", "Gallons", "Quarts", "Pints", "Cups", "Fluid Ounces"]
        }
    }
    
    var convertedValue: String {
        guard let input = Double(inputValue), !fromUnit.isEmpty, !toUnit.isEmpty else {
            return ""
        }
        
        let result = convert(value: input, from: fromUnit, to: toUnit, category: selectedCategory)
        
        // Handle special cases
        if result.isNaN || result.isInfinite {
            return "Error"
        }
        
        // Format the result properly
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.usesGroupingSeparator = false
        
        // Remove unnecessary trailing zeros
        if let formattedString = formatter.string(from: NSNumber(value: result)) {
            return formattedString
        }
        
        return String(result)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Unit Converter")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
                VStack(spacing: 16) {
                    // Category Selection Card - Compact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            ForEach(ConversionCategory.allCases, id: \.self) { category in
                                Button(action: { 
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category
                                        resetSelection()
                                    }
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? .white : category.color)
                                            .frame(width: 32, height: 32)
                                            .background(
                                                Circle()
                                                    .fill(selectedCategory == category ? category.color : category.color.opacity(0.1))
                                            )
                                        
                                        Text(category.rawValue)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(selectedCategory == category ? category.color : .secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedCategory == category ? category.color.opacity(0.08) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedCategory == category ? category.color.opacity(0.3) : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
                    )
                    
                    // Input Value Card - Compact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Amount")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter value", text: $inputValue)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 20, weight: .medium))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.cardBackground.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
                    )
                    
                    // Unit Selection Card - Compact
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            // From Unit
                            VStack(alignment: .leading, spacing: 8) {
                                Text("From")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(availableUnits, id: \.self) { unit in
                                        Button(unit) {
                                            fromUnit = unit
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(fromUnit.isEmpty ? "Select" : fromUnit)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(fromUnit.isEmpty ? .secondary : .primary)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.cardBackground.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            // Swap Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    swapUnits()
                                }
                            }) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(selectedCategory.color)
                                            .shadow(color: selectedCategory.color.opacity(0.3), radius: 3, x: 0, y: 1)
                                    )
                            }
                            .disabled(fromUnit.isEmpty || toUnit.isEmpty)
                            .opacity((fromUnit.isEmpty || toUnit.isEmpty) ? 0.5 : 1.0)
                            
                            // To Unit
                            VStack(alignment: .leading, spacing: 8) {
                                Text("To")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Menu {
                                    ForEach(availableUnits, id: \.self) { unit in
                                        Button(unit) {
                                            toUnit = unit
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(toUnit.isEmpty ? "Select" : toUnit)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(toUnit.isEmpty ? .secondary : .primary)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.cardBackground.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
                    )
                    
                    // Result Card - Compact
                    if !convertedValue.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "equal.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedCategory.color)
                                
                                Text("Result")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                Text(convertedValue)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                
                                Text(toUnit)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedCategory.color.opacity(0.1))
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedCategory.color.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCategory.color.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 3)
                        )
                    }
                    
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .onAppear {
            if fromUnit.isEmpty && !availableUnits.isEmpty {
                fromUnit = availableUnits[0]
                toUnit = availableUnits.count > 1 ? availableUnits[1] : availableUnits[0]
            }
        }
    }
    
    // MARK: - Functions
    
    private func resetSelection() {
        inputValue = ""
        fromUnit = availableUnits.first ?? ""
        toUnit = availableUnits.count > 1 ? availableUnits[1] : availableUnits.first ?? ""
    }
    
    private func swapUnits() {
        let temp = fromUnit
        fromUnit = toUnit
        toUnit = temp
    }
    
    private func convert(value: Double, from: String, to: String, category: ConversionCategory) -> Double {
        switch category {
        case .length:
            return convertLength(value: value, from: from, to: to)
        case .weight:
            return convertWeight(value: value, from: from, to: to)
        case .temperature:
            return convertTemperature(value: value, from: from, to: to)
        case .volume:
            return convertVolume(value: value, from: from, to: to)
        }
    }
    
    private func convertLength(value: Double, from: String, to: String) -> Double {
        // Convert to meters first
        let inMeters: Double
        switch from {
        case "Meters": inMeters = value
        case "Kilometers": inMeters = value * 1000
        case "Centimeters": inMeters = value / 100
        case "Millimeters": inMeters = value / 1000
        case "Inches": inMeters = value * 0.0254
        case "Feet": inMeters = value * 0.3048
        case "Yards": inMeters = value * 0.9144
        case "Miles": inMeters = value * 1609.34
        default: inMeters = value
        }
        
        // Convert from meters to target unit
        switch to {
        case "Meters": return inMeters
        case "Kilometers": return inMeters / 1000
        case "Centimeters": return inMeters * 100
        case "Millimeters": return inMeters * 1000
        case "Inches": return inMeters / 0.0254
        case "Feet": return inMeters / 0.3048
        case "Yards": return inMeters / 0.9144
        case "Miles": return inMeters / 1609.34
        default: return inMeters
        }
    }
    
    private func convertWeight(value: Double, from: String, to: String) -> Double {
        // Convert to grams first
        let inGrams: Double
        switch from {
        case "Grams": inGrams = value
        case "Kilograms": inGrams = value * 1000
        case "Pounds": inGrams = value * 453.592
        case "Ounces": inGrams = value * 28.3495
        case "Tons": inGrams = value * 1000000
        case "Stones": inGrams = value * 6350.29
        default: inGrams = value
        }
        
        // Convert from grams to target unit
        switch to {
        case "Grams": return inGrams
        case "Kilograms": return inGrams / 1000
        case "Pounds": return inGrams / 453.592
        case "Ounces": return inGrams / 28.3495
        case "Tons": return inGrams / 1000000
        case "Stones": return inGrams / 6350.29
        default: return inGrams
        }
    }
    
    private func convertTemperature(value: Double, from: String, to: String) -> Double {
        // Convert to Celsius first
        let inCelsius: Double
        switch from {
        case "Celsius": inCelsius = value
        case "Fahrenheit": inCelsius = (value - 32) * 5/9
        case "Kelvin": inCelsius = value - 273.15
        default: inCelsius = value
        }
        
        // Convert from Celsius to target unit
        switch to {
        case "Celsius": return inCelsius
        case "Fahrenheit": return inCelsius * 9/5 + 32
        case "Kelvin": return inCelsius + 273.15
        default: return inCelsius
        }
    }
    
    private func convertVolume(value: Double, from: String, to: String) -> Double {
        // Convert to liters first
        let inLiters: Double
        switch from {
        case "Liters": inLiters = value
        case "Milliliters": inLiters = value / 1000
        case "Gallons": inLiters = value * 3.78541
        case "Quarts": inLiters = value * 0.946353
        case "Pints": inLiters = value * 0.473176
        case "Cups": inLiters = value * 0.236588
        case "Fluid Ounces": inLiters = value * 0.0295735
        default: inLiters = value
        }
        
        // Convert from liters to target unit
        switch to {
        case "Liters": return inLiters
        case "Milliliters": return inLiters * 1000
        case "Gallons": return inLiters / 3.78541
        case "Quarts": return inLiters / 0.946353
        case "Pints": return inLiters / 0.473176
        case "Cups": return inLiters / 0.236588
        case "Fluid Ounces": return inLiters / 0.0295735
        default: return inLiters
        }
    }
}

#Preview {
    UnitConverterView()
}
