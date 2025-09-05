//
//  TodoView.swift
//  Utilities App
//
//  Created by Danciu David on 05.09.2025.
//

import SwiftUI

struct TodoItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var dateCreated: Date
    var dateCompleted: Date?
    var priority: Priority
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
}

enum TodoSortOption: String, CaseIterable {
    case priority = "Priority"
    case dateCreated = "Date Created"
    case alphabetical = "A-Z"
}

struct TodoView: View {
    @State private var todos: [TodoItem] = []
    @State private var showingAddTodo = false
    @State private var newTodoTitle = ""
    @State private var selectedPriority: TodoItem.Priority = .medium
    @State private var showingCompletedTasks = true
    @State private var sortOption: TodoSortOption = .priority
    
    // Premium color scheme
    let primaryBlue = Color(hex: "#53AAEA")
    let accentGreen = Color(hex: "#66D9A7")
    let darkTeal = Color(hex: "#224F55")
    
    var incompleteTodos: [TodoItem] {
        let filtered = todos.filter { !$0.isCompleted }
        return sortTodos(filtered)
    }
    
    var completedTodos: [TodoItem] {
        let filtered = todos.filter { $0.isCompleted }
        return filtered.sorted { $0.dateCompleted ?? Date() > $1.dateCompleted ?? Date() }
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Sort
                VStack(spacing: 12) {
                    HStack {
                        Text("To-Do List")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showingAddTodo = true
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
                    
                    // Sort Options
                    if !todos.isEmpty {
                        HStack {
                            Text("Sort by:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Picker("Sort", selection: $sortOption) {
                                ForEach(TodoSortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .scaleEffect(0.8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Stats Card
                if !todos.isEmpty {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            PremiumStatCard(title: "Total", value: "\(todos.count)", color: primaryBlue, icon: "list.bullet")
                            PremiumStatCard(title: "Pending", value: "\(incompleteTodos.count)", color: Color.orange, icon: "clock")
                            PremiumStatCard(title: "Done", value: "\(completedTodos.count)", color: accentGreen, icon: "checkmark")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            
                if todos.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(primaryBlue.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checklist")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(primaryBlue.opacity(0.6))
                        }
                        
                        VStack(spacing: 12) {
                            Text("No tasks yet")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Tap the + button to create your first task")
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
                        LazyVStack(spacing: 16) {
                            // Pending tasks section
                            if !incompleteTodos.isEmpty {
                                TaskSectionCard(
                                    title: "Pending Tasks",
                                    count: incompleteTodos.count,
                                    tasks: incompleteTodos,
                                    primaryColor: primaryBlue,
                                    accentColor: Color.orange,
                                    onToggle: toggleTodo,
                                    onDelete: { todo in deleteTodo(todo) }
                                )
                            }
                            
                            // Completed tasks section
                            if !completedTodos.isEmpty {
                                CollapsibleTaskSection(
                                    isExpanded: $showingCompletedTasks,
                                    completedTodos: completedTodos,
                                    primaryColor: primaryBlue,
                                    accentColor: accentGreen,
                                    onToggle: toggleTodo,
                                    onDelete: { todo in deleteTodo(todo) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView { title, priority in
                addTodo(title: title, priority: priority)
            }
        }
        .onAppear {
            loadTodos()
        }
    }
    
    // MARK: - Functions
    
    private func addTodo(title: String, priority: TodoItem.Priority) {
        let newTodo = TodoItem(
            title: title,
            isCompleted: false,
            dateCreated: Date(),
            priority: priority
        )
        todos.append(newTodo)
        saveTodos()
    }
    
    private func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            todos[index].dateCompleted = todos[index].isCompleted ? Date() : nil
            saveTodos()
        }
    }
    
    private func deleteTodos(from list: [TodoItem], at indexSet: IndexSet) {
        let idsToDelete = indexSet.map { list[$0].id }
        todos.removeAll { idsToDelete.contains($0.id) }
        saveTodos()
    }
    
    private func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    private func sortTodos(_ todos: [TodoItem]) -> [TodoItem] {
        switch sortOption {
        case .priority:
            return todos.sorted { todo1, todo2 in
                if todo1.priority != todo2.priority {
                    return priorityOrder(todo1.priority) < priorityOrder(todo2.priority)
                }
                return todo1.dateCreated < todo2.dateCreated
            }
        case .dateCreated:
            return todos.sorted { $0.dateCreated > $1.dateCreated }
        case .alphabetical:
            return todos.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }
    
    private func priorityOrder(_ priority: TodoItem.Priority) -> Int {
        switch priority {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: "SavedTodos")
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "SavedTodos"),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
}

// Replaced with PremiumTodoRow

struct PremiumStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct TaskSectionCard: View {
    let title: String
    let count: Int
    let tasks: [TodoItem]
    let primaryColor: Color
    let accentColor: Color
    let onToggle: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(accentColor)
                    )
            }
            
            // Tasks
            ForEach(tasks) { task in
                PremiumTodoRow(task: task, primaryColor: primaryColor, onToggle: onToggle, onDelete: onDelete)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct CollapsibleTaskSection: View {
    @Binding var isExpanded: Bool
    let completedTodos: [TodoItem]
    let primaryColor: Color
    let accentColor: Color
    let onToggle: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Collapsible header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 8, height: 8)
                        
                        Text("Completed Tasks")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("\(completedTodos.count)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor)
                        )
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content
            if isExpanded {
                ForEach(completedTodos) { task in
                    PremiumTodoRow(task: task, primaryColor: primaryColor, onToggle: onToggle, onDelete: onDelete)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct PremiumTodoRow: View {
    let task: TodoItem
    let primaryColor: Color
    let onToggle: (TodoItem) -> Void
    let onDelete: (TodoItem) -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    onToggle(task)
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? task.priority.color : Color.secondary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(task.priority.color)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    // Priority badge
                    Text(task.priority.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(task.priority.color)
                        )
                    
                    Text(formatDate(task.isCompleted ? (task.dateCompleted ?? Date()) : task.dateCreated))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: { showingDeleteConfirmation = true }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
        .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDelete(task)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            return "Today"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
                  calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    TodoView()
}
