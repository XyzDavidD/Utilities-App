//
//  NotesView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var dateCreated: Date
    var dateModified: Date
}

struct NotesView: View {
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @State private var searchText = ""
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes.sorted { $0.dateModified > $1.dateModified }
        } else {
            return notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateModified > $1.dateModified }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Notes")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showingAddNote = true
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [primaryBlue, accentGreen],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                    // Search Bar
                    if !notes.isEmpty {
                        PremiumSearchBar(text: $searchText, primaryColor: primaryBlue)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                
                    // Notes List
                    if filteredNotes.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(primaryBlue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "note.text")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(primaryBlue.opacity(0.6))
                            }
                            
                            VStack(spacing: 12) {
                                Text(notes.isEmpty ? "No notes yet" : "No matching notes")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(notes.isEmpty ? "Tap the + button to create your first note" : "Try adjusting your search")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredNotes) { note in
                                    NavigationLink(destination: NoteDetailView(note: note, onSave: updateNote, onDelete: deleteNote)) {
                                        PremiumNoteCard(note: note, primaryColor: primaryBlue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(onSave: addNote)
        }
        .onAppear {
            loadNotes()
        }
    }
    
    // MARK: - Functions
    
    private func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    private func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            notes[index] = updatedNote
            saveNotes()
        }
    }
    
    private func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func deleteNotes(offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "SavedNotes")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "SavedNotes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
}

// Removed old NoteRowView - replaced with PremiumNoteCard

struct PremiumSearchBar: View {
    @Binding var text: String
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search your notes...", text: $text)
                .font(.system(size: 16, weight: .medium))
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct PremiumNoteCard: View {
    let note: Note
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(note.title.isEmpty ? "Untitled Note" : note.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    } else {
                        Text("No content")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            
            HStack {
                Text(formatDate(note.dateModified))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Note indicator
                Circle()
                    .fill(primaryColor.opacity(0.6))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
                  calendar.isDate(date, inSameDayAs: yesterday) {
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NotesView()
}
