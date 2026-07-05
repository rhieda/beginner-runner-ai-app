//
//  ContentView.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VitalsDashboardView(onOpenSandbox: {
                path.append("sandbox")
            })
            .navigationDestination(for: String.self) { value in
                if value == "sandbox" {
                    SandboxView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
