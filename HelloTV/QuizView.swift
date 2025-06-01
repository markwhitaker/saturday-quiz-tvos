//
//  ContentView.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

protocol QuizViewing {
}

struct QuizView: View, QuizViewing {
    var presenter: any QuizPresenting = QuizPresenter()
    
    @FocusState private var isFocused: Bool

    var body: some View {
        Grid(alignment: .topLeading, verticalSpacing: 20) {
            GridRow {
                Color.clear.frame(width: 0, height: 0)
                HStack(spacing: 10) {
                    Image(systemName: "link")
                    Text("What links")
                        .textCase(.uppercase)
                }
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(.secondary)
            }

            GridRow {
                Text("1.")
                Text("Question goes here even if it's a very very large question in which case the text will wrap...")
            }
            .font(.system(size: 64, weight: .light))

            GridRow {
                Color.clear.frame(width: 0, height: 0)
                Text("Answer goes here...")
            }
            .font(.system(size: 64, weight: .light))
            .foregroundStyle(.yellow)
            
            GridRow {
                VStack {
                    Spacer()
                }
            }
            
            GridRow {
                ZStack {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 5)
                        .frame(width: 100, height: 100)
                        
                    Image(systemName: "checkmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .focusable()
        .focused($isFocused)
        .padding()
        .onAppear {
            isFocused = true
            presenter.onViewReady(view: self)
        }
        .onMoveCommand { direction in
            switch direction {
            case .left:
                debugPrint("Left pressed")
            case .right:
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
