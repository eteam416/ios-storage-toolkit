import SwiftUI

/// Quick notes view for browsing notes.
struct NotesView: View {
    @EnvironmentObject private var notesManager: NotesManager
    @Environment(\.dismiss) private var dismiss

    @State private var showNewNote = false
    @State private var newNoteContent = ""
    @State private var selectedColor: BrowsingNote.NoteColor = .yellow
    @State private var editingNote: BrowsingNote?

    var currentURL: String?
    var currentTitle: String?
    let onOpenURL: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if notesManager.notes.isEmpty {
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle(String(localized: "notes_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewNote) {
                noteEditor(note: nil)
            }
            .sheet(item: $editingNote) { note in
                noteEditor(note: note)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AegisSpacing.lg) {
            Image(systemName: "note.text")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AegisColors.textTertiary)
            Text(String(localized: "no_notes_title"))
                .font(AegisTypography.headlineSmall)
            Text(String(localized: "no_notes_subtitle"))
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AegisSpacing.xl)
    }

    private var notesList: some View {
        List {
            ForEach(notesManager.notes) { note in
                noteCard(note)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func noteCard(_ note: BrowsingNote) -> some View {
        Button {
            editingNote = note
        } label: {
            VStack(alignment: .leading, spacing: AegisSpacing.xs) {
                // Note content
                Text(note.content)
                    .font(AegisTypography.bodyMedium)
                    .foregroundStyle(AegisColors.textPrimary)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    // Associated page
                    if let domain = note.displayDomain {
                        Label(domain, systemImage: "link")
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.brandAccent)
                    }

                    Spacer()

                    // Timestamp
                    Text(note.updatedAt, style: .relative)
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                }

                // Color indicator
                Circle()
                    .fill(note.color.swiftUIColor)
                    .frame(width: 8, height: 8)
            }
            .padding(.vertical, AegisSpacing.xxs)
        }
        .listRowBackground(note.color.backgroundColor)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                notesManager.deleteNote(note)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
        .contextMenu {
            if let url = note.associatedURL {
                Button {
                    onOpenURL?(url)
                    dismiss()
                } label: {
                    Label(String(localized: "open_page_button"), systemImage: "safari")
                }
            }

            Button(role: .destructive) {
                notesManager.deleteNote(note)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
    }

    // MARK: - Note Editor

    private func noteEditor(note: BrowsingNote?) -> some View {
        NavigationStack {
            VStack(spacing: AegisSpacing.md) {
                // Color picker
                HStack(spacing: AegisSpacing.sm) {
                    ForEach(BrowsingNote.NoteColor.allCases, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            Circle()
                                .fill(color.swiftUIColor)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                }
                .padding(.top, AegisSpacing.sm)

                // Associated page info
                if let title = (note != nil ? note?.associatedTitle : currentTitle) ?? currentTitle {
                    HStack {
                        Image(systemName: "link")
                            .font(.caption)
                            .foregroundStyle(AegisColors.textTertiary)
                        Text(title)
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.textSecondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, AegisSpacing.md)
                }

                // Text editor
                TextEditor(text: $newNoteContent)
                    .font(AegisTypography.bodyMedium)
                    .padding(AegisSpacing.sm)
                    .scrollContentBackground(.hidden)
                    .background(selectedColor.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, AegisSpacing.md)

                Spacer()
            }
            .navigationTitle(note == nil
                ? String(localized: "new_note_title")
                : String(localized: "edit_note_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel_button")) {
                        showNewNote = false
                        editingNote = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save_button")) {
                        if let note {
                            notesManager.updateNote(note, content: newNoteContent)
                            notesManager.updateNoteColor(note, color: selectedColor)
                        } else if !newNoteContent.isEmpty {
                            notesManager.addNote(
                                content: newNoteContent,
                                associatedURL: currentURL,
                                associatedTitle: currentTitle,
                                color: selectedColor
                            )
                        }
                        newNoteContent = ""
                        showNewNote = false
                        editingNote = nil
                    }
                    .disabled(newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let note {
                    newNoteContent = note.content
                    selectedColor = note.color
                } else {
                    newNoteContent = ""
                    selectedColor = .yellow
                }
            }
        }
    }
}
