//
//  ContentView.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

struct QuizView: View {
    @StateObject var presenter = QuizPresenter()
    
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
            if let quiz = presenter.quiz {
                Text(quiz.title)
                    .font(.title2)
                    .padding()
            }
        }
        .padding()
        .onAppear(perform: presenter.fetchQuiz)
    }
}

#Preview {
    QuizView()
}
