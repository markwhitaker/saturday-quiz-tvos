//
//  ContentView.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "appletv")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding()
            Text("Hello, TV")
                .font(.headline)
                .padding(.bottom)
            Text("We’ve been expecting you")
                .font(.caption)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
