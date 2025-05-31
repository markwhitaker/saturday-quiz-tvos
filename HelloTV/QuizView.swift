//
//  ContentView.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

struct QuizView: View {
    @StateObject var presenter = QuizPresenter()
    
    @FocusState private var isFocused: Bool

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
                Text(quiz.questions.first?.question ?? "No question found")
                    .font(.title2)
                    .padding()
            }
        }
        .focusable()
        .focused($isFocused)
        .padding()
        .onAppear {
            isFocused = true
            presenter.start()
        }
        .onMoveCommand(perform: { direction in
                    debugPrint("move \(direction)")
                })
//        .onMoveCommand { direction in
//            switch direction {
//            case .left:
//                debugPrint("Left pressed")
//            case .right:
//                debugPrint("Right pressed")
//            default:
//                break
//            }
//        }
    }
}

#Preview {
    QuizView()
}
