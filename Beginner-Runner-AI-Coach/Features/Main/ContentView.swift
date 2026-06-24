//
//  ContentView.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import SwiftUI

struct ContentView: View {
    @State var i: Int = 0
    @State var path = NavigationPath()
    @State var shouldPresentSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                NavigationLink {
                    SandboxView()
                } label: {
                    Label("Open Provider Sandbox", systemImage: "testtube.2")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text("Developer Testing Area")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Main Menu")
        }
    }
}

#Preview {
    ContentView()
}
