//
//  ContentView.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]

//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
    @State var i: Int = 0
    @State var path = NavigationPath()
    @State var shouldPresentSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("one") {
                    path.append("one")
                }
                Button("two") {
                    path.append(2)
                }
                Button("Present") {
                    shouldPresentSheet.toggle()
                }.sheet(isPresented: $shouldPresentSheet) {
                    Button("Hello Present") {
                         
                    }
                }
            }.navigationTitle("Navigation tests")
            .navigationDestination(for: Int.self) { selection in
                Text("You selected the number \(selection)")
            }.navigationDestination(for: String.self) { selection in
                Text("You selected the string \(selection)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
