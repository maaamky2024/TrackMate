//
//  PromptListView.swift
//  TrackMate
//
//  Created by Glen Mars on 5/21/25.
//

import SwiftUI
import CoreData

struct PromptListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Prompt.createdAt, ascending: false)],
        animation: .default
    ) private var prompts: FetchedResults<Prompt>
    
    @State private var newPromptText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                Section(
                    header: Text("Add New Prompt")
                    .font(.headline)
                    .foregroundColor(themeManager.color("PrimaryText"))
                ) {
                    
                    HStack {
                        TextField(
                            "Enter prompt...", text: $newPromptText)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .foregroundColor(themeManager.color("PrimaryText"))
                        
                        Button(action: addPrompt) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(newPromptText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Section(
                    header: Text("Your Prompts")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                ) {
                    
                    ForEach(prompts) { prompt in
                        Text(prompt.text ?? "")
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                    .onDelete(perform: deletePrompts)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Manage Prompts")
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .font(.title)
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
    
    private func addPrompt() {
        let p = Prompt(context: viewContext)
        p.id = UUID()
        p.text = newPromptText.trimmingCharacters(in: .whitespaces)
        p.createdAt = Date()
        do {
            try viewContext.save()
            newPromptText = ""
        } catch {
            print("Failed to save new prompt: \(error.localizedDescription)")
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

    }
    
    private func deletePrompts(offsets: IndexSet) {
        offsets.map { prompts[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete prompts: \(error.localizedDescription)")
        }
    }
}
