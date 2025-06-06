//
//  ContentView.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

struct FontSize {
    static let title: CGFloat = 100
    static let body: CGFloat = 50
    static let whatLinks: CGFloat = 30
    static let date: CGFloat = 40
}

struct QuizView: View {
    @StateObject var presenter = QuizPresenter()

    @FocusState private var isFocused: Bool
    
    private var dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "d MMM yyyy"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch presenter.currentScene {
                case .loading:
                    LoadingView()
                case .ready(let date):
                    ReadyView(date: date)
                case .question(let number, let type, let question):
                    QuestionView(number: number, type: type, question: question)
                case .answersTitle:
                    AnswersTitleView()
                case .questionAnswer(let number, let type, let question, let answer):
                    QuestionAndAnswerView(
                        number: number,
                        type: type,
                        question: question,
                        answer: answer,
                        score: presenter.scores[number - 1]
                    )
                case .results:
                    Text("Results...")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        }
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
            case .right:
                presenter.next()
            default:
                break
            }
        }
        .onPlayPauseCommand {
            if case .questionAnswer(let number, _, _, _) = presenter.currentScene {
                presenter.cycleScore(for: number)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct ReadyView: View {
    let date: String
    let dateFormatter: DateFormatter
    
    init(date: Date) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        self.date = dateFormatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Text(date)
                .font(.custom("Open Sans", size: FontSize.date))
                .fontWeight(.thin)
                .foregroundColor(.yellow)
                .padding(.bottom, 400)
                .textCase(.uppercase)
            
            Text("Ready?")
                .font(.custom("Open Sans", size: FontSize.title))
                .fontWeight(.thin)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct QuestionView: View {
    let number: Int
    let isWhatLinks: Bool
    let question: String
    
    init(number: Int, type: QuestionType, question: String) {
        self.number = number
        self.question = question
        self.isWhatLinks = type == .whatLinks
    }
    
    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 20) {
            GridRow {
                Color.clear.frame(width: 0, height: 0)
                HStack(spacing: 10) {
                    Image(systemName: "link")
                    Text("What links")
                        .textCase(.uppercase)
                }
                .font(.custom("Open Sans", size: FontSize.whatLinks))
                .fontWeight(.black)
                .foregroundStyle(.tertiary)
                .opacity(isWhatLinks ? 1 : 0)
            }

            GridRow {
                Text("\(number).")
                    .frame(width: 120, alignment: .topLeading)
                Text(question)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

    }
}

struct AnswersTitleView: View {
    var body: some View {
        ZStack {
            Text("Answers")
                .font(.custom("Open Sans", size: FontSize.title))
                .fontWeight(.thin)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct QuestionAndAnswerView: View {
    let number: Int
    let isWhatLinks: Bool
    let question: String
    let answer: String
    let score: ScoreState
    
    init(number: Int, type: QuestionType, question: String, answer: String, score: ScoreState) {
        self.number = number
        self.question = question
        self.answer = answer
        self.score = score
        self.isWhatLinks = type == .whatLinks
    }
    
    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 20) {
            GridRow {
                Color.clear.frame(width: 0, height: 0)
                HStack(spacing: 10) {
                    Image(systemName: "link")
                    Text("What links")
                        .textCase(.uppercase)
                }
                .font(.custom("Open Sans", size: FontSize.whatLinks))
                .fontWeight(.black)
                .foregroundStyle(.tertiary)
                .opacity(isWhatLinks ? 1 : 0)
            }

            GridRow {
                Text("\(number).")
                    .frame(width: 120, alignment: .topLeading)
                Text(question)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)

            GridRow {
                Color.clear.frame(width: 0, height: 0)
                Text(answer)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)
            .foregroundStyle(.yellow)

            GridRow {
                VStack {
                    Spacer()
                }
            }

            GridRow {
                ScoreIndicatorView(score: score)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

    }
}

struct ScoreIndicatorView: View {
    let score: ScoreState
    
    var body: some View {
        ZStack {
            switch score {
            case .none:
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: 80, height: 80)
            case .full:
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .fill(Color.yellow)
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
            case .half:
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
    }
}

#Preview("Loading view") {
    ZStack {
        LoadingView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Ready view") {
    ZStack {
        ReadyView(date: Date())
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Question view: normal") {
    ZStack {
        QuestionView(number: 4, type: .normal, question: "Which sci-fi writer was the first person in Europe to buy a Mac computer?")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Question view: what links") {
    ZStack {
        QuestionView(number: 4, type: .whatLinks, question: "Observatory Circle resident; reclusive New Hampshire author; Tim Martin's pubs; Wardle and Makin's shops?")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Answers title view") {
    ZStack {
        AnswersTitleView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Question/answer view: normal") {
    ZStack {
        QuestionAndAnswerView(number: 4, type: .normal, question: "Which sci-fi writer was the first person in Europe to buy a Mac computer?", answer: "Douglas Adams (Stephen Fry was the second)", score: .full)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Question/answer view: what links") {
    ZStack {
        QuestionAndAnswerView(number: 4, type: .whatLinks, question: "Observatory Circle resident; reclusive New Hampshire author; Tim Martin's pubs; Wardle and Makin's shops?", answer: "JD: JD Vance; JD Salinger; JD Wetherspoon; JD Sports", score: .half)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
