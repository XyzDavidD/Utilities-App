//
//  AddTodoView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var selectedPriority: TodoItem.Priority = .medium
    let onSave: (String, TodoItem.Priority) -> Void
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Field Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Task Title")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("Enter task title...", text: $title)
                                .font(.system(size: 16, weight: .medium))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.tertiarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(primaryBlue.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        // Priority Selection Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Priority Level")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                                    Button(action: { 
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedPriority = priority
                                        }
                                    }) {
                                        HStack(spacing: 16) {
                                            // Priority indicator
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 16, height: 16)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedPriority == priority ? 2 : 0)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(priority.rawValue)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                
                                                Text(priorityDescription(priority))
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedPriority == priority {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(priority.color)
                                            } else {
                                                Circle()
                                                    .stroke(Color.secondary, lineWidth: 1)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedPriority == priority ? priority.color.opacity(0.08) : Color.cardBackground.opacity(0.6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(selectedPriority == priority ? priority.color.opacity(0.3) : Color.clear, lineWidth: 1.5)
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary),
                trailing: Button("Save") {
                    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        // Haptic + alert via simple sheetless approach using notification feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                    } else {
                        saveTodo()
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(primaryBlue)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func priorityDescription(_ priority: TodoItem.Priority) -> String {
        switch priority {
        case .high: return "Urgent and important"
        case .medium: return "Important but not urgent"
        case .low: return "Nice to have"
        }
    }
    
    private func saveTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            onSave(trimmedTitle, selectedPriority)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AddTodoView { _, _ in }
}
