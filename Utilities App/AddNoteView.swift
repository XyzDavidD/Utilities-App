//
//  AddNoteView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var content = ""
    let onSave: (Note) -> Void
    
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
                            Text("Title")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            TextField("Enter note title...", text: $title)
                                .font(.system(size: 16, weight: .medium))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.fieldBackground)
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
                        
                        // Content Field Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Content")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.fieldBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(primaryBlue.opacity(0.2), lineWidth: 1)
                                    )
                                    .frame(minHeight: 200)
                                
                                if content.isEmpty {
                                                                    Text("Write your note here...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                        .padding(16)
                                }
                                
                                TextEditor(text: $content)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(12)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 200)
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
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary),
                trailing: Button("Save") {
                    let bothEmpty = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                                     content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    if bothEmpty {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                    } else {
                        saveNote()
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(primaryBlue)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                         content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func saveNote() {
        let newNote = Note(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            dateCreated: Date(),
            dateModified: Date()
        )
        onSave(newNote)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddNoteView { _ in }
}
