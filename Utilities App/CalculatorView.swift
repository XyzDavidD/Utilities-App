//
//  CalculatorView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct CalculationHistory: Identifiable, Codable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp: Date
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var previousNumber: Double = 0
    @State private var operation: CalculatorOperation = .none
    @State private var userIsInTheMiddleOfTyping = false
    @State private var currentExpression = ""
    @State private var showHistory = false
    @State private var history: [CalculationHistory] = []
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with history button
                HStack {
                    Text("Calculator")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { showHistory.toggle() }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(primaryBlue)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(primaryBlue.opacity(0.1))
                            )
                    }
                    .disabled(history.isEmpty)
                    .opacity(history.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Display Card - Fixed Height
                VStack(spacing: 16) {
                    // Expression display
                    HStack {
                        Spacer()
                        Text(currentExpression.isEmpty ? " " : currentExpression)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(height: 20)
                    
                    // Main display
                    HStack {
                        Spacer()
                        Text(display)
                            .font(.system(size: 48, weight: .light, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    .frame(height: 60)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Button Grid Card
                VStack(spacing: 16) {
                    // Row 1: Clear, +/-, %, ÷
                    HStack(spacing: 16) {
                        PremiumCalculatorButton(title: "C", style: .secondary) {
                            clearCalculator()
                        }
                        PremiumCalculatorButton(title: "±", style: .secondary) {
                            toggleSign()
                        }
                        PremiumCalculatorButton(title: "%", style: .secondary) {
                            performOperation(.percent)
                        }
                        PremiumCalculatorButton(title: "÷", style: .operation, primaryColor: primaryBlue) {
                            performOperation(.divide)
                        }
                    }
                    
                    // Row 2: 7, 8, 9, ×
                    HStack(spacing: 16) {
                        PremiumCalculatorButton(title: "7", style: .number) { numberPressed("7") }
                        PremiumCalculatorButton(title: "8", style: .number) { numberPressed("8") }
                        PremiumCalculatorButton(title: "9", style: .number) { numberPressed("9") }
                        PremiumCalculatorButton(title: "×", style: .operation, primaryColor: primaryBlue) {
                            performOperation(.multiply)
                        }
                    }
                    
                    // Row 3: 4, 5, 6, -
                    HStack(spacing: 16) {
                        PremiumCalculatorButton(title: "4", style: .number) { numberPressed("4") }
                        PremiumCalculatorButton(title: "5", style: .number) { numberPressed("5") }
                        PremiumCalculatorButton(title: "6", style: .number) { numberPressed("6") }
                        PremiumCalculatorButton(title: "−", style: .operation, primaryColor: primaryBlue) {
                            performOperation(.subtract)
                        }
                    }
                    
                    // Row 4: 1, 2, 3, +
                    HStack(spacing: 16) {
                        PremiumCalculatorButton(title: "1", style: .number) { numberPressed("1") }
                        PremiumCalculatorButton(title: "2", style: .number) { numberPressed("2") }
                        PremiumCalculatorButton(title: "3", style: .number) { numberPressed("3") }
                        PremiumCalculatorButton(title: "+", style: .operation, primaryColor: primaryBlue) {
                            performOperation(.add)
                        }
                    }
                    
                    // Row 5: 0, ., =
                    HStack(spacing: 16) {
                        PremiumCalculatorButton(title: "0", style: .number, isWide: true) { numberPressed("0") }
                        PremiumCalculatorButton(title: ".", style: .number) { decimalPressed() }
                        PremiumCalculatorButton(title: "=", style: .equals, primaryColor: accentGreen) {
                            performOperation(.equals)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(history: history, onClearHistory: clearHistory, primaryColor: primaryBlue)
        }
        .onAppear {
            loadHistory()
        }
    }
    
    // MARK: - Calculator Logic
    
    private func numberPressed(_ number: String) {
        if userIsInTheMiddleOfTyping {
            if display.count < 9 {
                display += number
            }
        } else {
            display = number
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private func decimalPressed() {
        if userIsInTheMiddleOfTyping {
            if !display.contains(".") && display.count < 8 {
                display += "."
            }
        } else {
            display = "0."
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private func clearCalculator() {
        display = "0"
        previousNumber = 0
        operation = .none
        userIsInTheMiddleOfTyping = false
        currentExpression = ""
    }
    
    private func toggleSign() {
        if display != "0" {
            if display.hasPrefix("-") {
                display = String(display.dropFirst())
            } else {
                display = "-" + display
            }
        }
    }
    
    private func performOperation(_ newOperation: CalculatorOperation) {
        if let displayValue = Double(display) {
            if userIsInTheMiddleOfTyping && operation != .none {
                let result = calculate(previousNumber, displayValue, operation)
                let formattedResult = formatResult(result)
                
                // Save to history
                let expression = "\(formatResult(previousNumber)) \(getOperationSymbol(operation)) \(display)"
                saveCalculation(expression: expression, result: formattedResult)
                
                display = formattedResult
                previousNumber = result
                currentExpression = ""
            } else {
                previousNumber = displayValue
            }
            
            userIsInTheMiddleOfTyping = false
            
            if newOperation == .equals {
                operation = .none
                currentExpression = ""
            } else if newOperation == .percent {
                let result = previousNumber / 100
                display = formatResult(result)
                previousNumber = result
                operation = .none
                currentExpression = ""
            } else {
                operation = newOperation
                currentExpression = "\(formatResult(previousNumber)) \(getOperationSymbol(newOperation))"
            }
        }
    }
    
    private func calculate(_ firstNumber: Double, _ secondNumber: Double, _ operation: CalculatorOperation) -> Double {
        switch operation {
        case .add: return firstNumber + secondNumber
        case .subtract: return firstNumber - secondNumber
        case .multiply: return firstNumber * secondNumber
        case .divide: return secondNumber != 0 ? firstNumber / secondNumber : 0
        case .percent: return firstNumber / 100
        case .equals, .none: return secondNumber
        }
    }
    
    private func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 && abs(result) < 1000000000 {
            return String(Int(result))
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 0
            return formatter.string(from: NSNumber(value: result)) ?? "Error"
        }
    }
    
    private func getOperationSymbol(_ operation: CalculatorOperation) -> String {
        switch operation {
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .percent: return "%"
        default: return ""
        }
    }
    
    // MARK: - History Management
    
    private func saveCalculation(expression: String, result: String) {
        let calculation = CalculationHistory(
            expression: expression,
            result: result,
            timestamp: Date()
        )
        history.insert(calculation, at: 0)
        
        // Keep only last 50 calculations
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        saveHistory()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "CalculatorHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "CalculatorHistory"),
           let decoded = try? JSONDecoder().decode([CalculationHistory].self, from: data) {
            history = decoded
        }
    }
    
    private func clearHistory() {
        history.removeAll()
        saveHistory()
    }
}

enum CalculatorOperation {
    case add, subtract, multiply, divide, percent, equals, none
}

enum ButtonStyle {
    case number, operation, secondary, equals
}

struct PremiumCalculatorButton: View {
    let title: String
    let style: ButtonStyle
    var primaryColor: Color = Color.blue
    var isWide: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var backgroundColor: Color {
        switch style {
        case .number:
            return Color.fieldBackground
        case .operation:
            return primaryColor
        case .secondary:
            return Color(.quaternarySystemFill)
        case .equals:
            return primaryColor
        }
    }
    
    var foregroundColor: Color {
        switch style {
        case .number, .secondary:
            return .primary
        case .operation, .equals:
            return .white
        }
    }
    
    var body: some View {
        Button(action: {
            action()
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(width: isWide ? 156 : 70, height: 72)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    let history: [CalculationHistory]
    let onClearHistory: () -> Void
    let primaryColor: Color
    
    var body: some View {
        NavigationView {
            VStack {
                if history.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No calculations yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Your calculation history will appear here")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(history) { calculation in
                            HistoryRowView(calculation: calculation)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Clear") {
                    onClearHistory()
                }
                .disabled(history.isEmpty)
            )
        }
    }
}

struct HistoryRowView: View {
    let calculation: CalculationHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(calculation.expression)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(calculation.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("= \(calculation.result)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    CalculatorView()
}
