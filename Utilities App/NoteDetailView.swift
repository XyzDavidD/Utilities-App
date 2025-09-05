//
//  NoteDetailView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var content: String
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    let note: Note
    let onSave: (Note) -> Void
    let onDelete: (Note) -> Void
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    init(note: Note, onSave: @escaping (Note) -> Void, onDelete: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if isEditing {
                // Edit Mode
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
                                    .frame(minHeight: 300)
                                
                                if content.isEmpty {
                                    Text("Write your note here...")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                        .padding(16)
                                }
                                
                                TextEditor(text: $content)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(12)
                                    .background(Color.clear)
                                    .frame(minHeight: 300)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            } else {
                // View Mode
                ScrollView {
                    VStack(spacing: 24) {
                        // Note Content Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Title
                            if !title.isEmpty {
                                Text(title)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            // Date info card
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Created: \(formatDate(note.dateCreated))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                if note.dateModified != note.dateCreated {
                                    Text("Modified: \(formatDate(note.dateModified))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(primaryBlue.opacity(0.08))
                            )
                            
                            // Content - Fixed Width Container
                            VStack(alignment: .leading) {
                                if !content.isEmpty {
                                    Text(content)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                        .lineSpacing(6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No content")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .italic()
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.fieldBackground)
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: HStack(spacing: 15) {
                if isEditing {
                    Button("Cancel") {
                        // Reset to original values
                        title = note.title
                        content = note.content
                        isEditing = false
                    }
                    .foregroundColor(.secondary)
                    
                    Button("Save") {
                        saveNote()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryBlue)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                             content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    }
                    
                    Button("Edit") {
                        isEditing = true
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryBlue)
                }
            }
        )
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete(note)
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
    
    private func saveNote() {
        var updatedNote = note
        updatedNote.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedNote.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedNote.dateModified = Date()
        
        onSave(updatedNote)
        isEditing = false
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        NoteDetailView(
            note: Note(
                title: "Sample Note",
                content: "This is a sample note content.",
                dateCreated: Date(),
                dateModified: Date()
            ),
            onSave: { _ in },
            onDelete: { _ in }
        )
    }
}
