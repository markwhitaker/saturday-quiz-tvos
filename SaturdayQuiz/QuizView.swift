//
//  ContentView.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

protocol QuizViewing {
}

struct QuizView: View, QuizViewing {
    @StateObject var presenter = QuizPresenter()

    @FocusState private var isFocused: Bool
    
    private var dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "d MMM yyyy"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            Group {
                switch presenter.currentScene {
                case .loading:
                    Text("Loading...")
                case .ready(let date):
                    Text("Ready? \(dateFormatter.string(from: date))")
                case .question(let number, let type, let question):
                    Text("\(number). \(question)")
                case .answersTitle:
                    Text("Answers...")
                case .questionAnswer(let number, let type, let question, let answer):
                    Text("\(number). \(question) \(answer)")
                case .results:
                    Text("Results...")
                }
            }.foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        Grid(alignment: .topLeading, verticalSpacing: 20) {
//            GridRow {
//                Color.clear.frame(width: 0, height: 0)
//                HStack(spacing: 10) {
//                    Image(systemName: "link")
//                    Text("What links")
//                        .textCase(.uppercase)
//                }
//                .font(.system(size: 32, weight: .black))
//                .foregroundStyle(.secondary)
//            }
//
//            GridRow {
//                Text("1.")
//                Text("Question goes here even if it's a very very large question in which case the text will wrap...")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .font(.system(size: 64, weight: .light))
//
//            GridRow {
//                Color.clear.frame(width: 0, height: 0)
//                Text("Answer goes here...")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .font(.system(size: 64, weight: .light))
//            .foregroundStyle(.yellow)
//
//            GridRow {
//                VStack {
//                    Spacer()
//                }
//            }
//
//            GridRow {
//                ZStack {
//                    Circle()
//                        .stroke(Color.yellow, lineWidth: 5)
//                        .frame(width: 100, height: 100)
//
//                    Image(systemName: "checkmark")
//                        .font(.system(size: 48, weight: .bold))
//                        .foregroundColor(.yellow)
//                }
//            }
//        }
        .background(.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .focusable()
        .focused($isFocused)
        .padding(.zero)
        .onAppear {
            presenter.onViewReady()
            isFocused = true
        }
        .onMoveCommand { direction in
            switch direction {
            case .left:
                presenter.previous()
                debugPrint("Left pressed")
            case .right:
                presenter.next()
                debugPrint("Right pressed")
            default:
                break
            }
        }
    }
}

#Preview {
    QuizView()
}
