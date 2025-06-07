//
//  ContentView.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

struct FontSize {
    static let title: CGFloat = 120
    static let body: CGFloat = 70
    static let whatLinks: CGFloat = 35
    static let date: CGFloat = 50
    static let score: CGFloat = 60
}

struct Dimensions {
    static let numberWidth: CGFloat = 150
    static let gridSpacing: CGFloat = 20
    static let outerSpacing: CGFloat = 40
    static let scoreCircle: CGFloat = 100
    static let scoreTick: CGFloat = 50
    static let scoreCircleBorder: CGFloat = 3
    static let whatLinksSpacing: CGFloat = 10
}

struct Colors {
    static let text = Color(red: 221/255, green: 221/255, blue: 221/255)
    static let highlight = Color(red: 255/255, green: 221/255, blue: 0/255)
    static let midGray = Color(red: 102/255, green: 102/255, blue: 102/255)
    static let darkGray = Color(red: 68/255, green: 68/255, blue: 68/255)
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
                    ResultsView(score: presenter.totalScore)
                }
            }
            .foregroundStyle(Colors.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .focusable()
        .focused($isFocused)
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
        .onTapGesture {
            if case .questionAnswer(let number, _, _, _) = presenter.currentScene {
                presenter.cycleScore(for: number)
            }
        }
    }
}

struct LoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40) // 100% rounded corners (half of height)
                .frame(width: 80, height: 40)
                .foregroundColor(Colors.highlight)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(
                        Animation
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }
                }
        }
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
                .foregroundColor(Colors.highlight)
                .padding(.bottom, 400)
                .textCase(.uppercase)
            
            Text("Ready?")
                .font(.custom("Open Sans", size: FontSize.title))
                .fontWeight(.thin)
                .foregroundColor(Colors.text)
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
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: Dimensions.gridSpacing) {
            GridRow {
                Color.clear.frame(width: 0, height: 0)
                HStack(spacing: Dimensions.whatLinksSpacing) {
                    Image(systemName: "link")
                    Text("What links")
                        .textCase(.uppercase)
                }
                .font(.custom("Open Sans", size: FontSize.whatLinks))
                .fontWeight(.black)
                .foregroundStyle(Colors.midGray)
                .opacity(isWhatLinks ? 1 : 0)
            }

            GridRow {
                Text("\(number).")
                    .frame(width: Dimensions.numberWidth, alignment: .topLeading)
                Text(question)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)
            .foregroundStyle(Colors.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(Dimensions.outerSpacing)
    }
}

struct AnswersTitleView: View {
    var body: some View {
        ZStack {
            Text("Answers")
                .font(.custom("Open Sans", size: FontSize.title))
                .fontWeight(.thin)
                .foregroundColor(Colors.text)
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
        Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: Dimensions.gridSpacing) {
            GridRow {
                Color.clear.frame(width: 0, height: 0)
                HStack(spacing: Dimensions.whatLinksSpacing) {
                    Image(systemName: "link")
                    Text("What links")
                        .textCase(.uppercase)
                }
                .font(.custom("Open Sans", size: FontSize.whatLinks))
                .fontWeight(.black)
                .foregroundStyle(Colors.midGray)
                .opacity(isWhatLinks ? 1 : 0)
            }

            GridRow {
                Text("\(number).")
                    .frame(width: Dimensions.numberWidth, alignment: .topLeading)
                Text(question)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)
            .foregroundStyle(Colors.text)

            GridRow {
                Color.clear.frame(width: 0, height: 0)
                Text(answer)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .font(.custom("Open Sans", size: FontSize.body))
            .fontWeight(.light)
            .foregroundStyle(Colors.highlight)

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
        .padding(Dimensions.outerSpacing)
    }
}

struct ScoreIndicatorView: View {
    let score: ScoreState
    
    var body: some View {
        ZStack {
            switch score {
            case .none:
                Circle()
                    .stroke(Colors.darkGray, lineWidth: Dimensions.scoreCircleBorder)
                    .frame(width: Dimensions.scoreCircle, height: Dimensions.scoreCircle)
            case .full:
                Circle()
                    .stroke(Colors.highlight, lineWidth: Dimensions.scoreCircleBorder)
                    .fill(Colors.highlight)
                    .frame(width: Dimensions.scoreCircle, height: Dimensions.scoreCircle)
                Image(systemName: "checkmark")
                    .font(.system(size: Dimensions.scoreTick, weight: .bold))
                    .foregroundColor(.black)
            case .half:
                Circle()
                    .stroke(Colors.darkGray, lineWidth: Dimensions.scoreCircleBorder)
                    .frame(width: Dimensions.scoreCircle, height: Dimensions.scoreCircle)
                Image(systemName: "checkmark")
                    .font(.system(size: Dimensions.scoreTick, weight: .bold))
                    .foregroundColor(Colors.highlight)
            }
        }
    }
}

struct ResultsView: View {
    let scoreString: String
    
    init(score: Double) {
        var s = "\(Int(score))"
        if (score.rounded(.down) < score) {
            s.append("½")
        }
        scoreString = s
    }
    
    var body: some View {
        ZStack {
            Text("End")
                .font(.custom("Open Sans", size: FontSize.title))
                .fontWeight(.thin)
                .foregroundColor(Colors.text)

            Text("Total score: \(scoreString)")
                .font(.custom("Open Sans", size: FontSize.score))
                .fontWeight(.thin)
                .foregroundColor(Colors.highlight)
                .padding(.top, 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        QuestionView(number: 10, type: .whatLinks, question: "Observatory Circle resident; reclusive New Hampshire author; Tim Martin's pubs; Wardle and Makin's shops?")
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
        QuestionAndAnswerView(number: 10, type: .whatLinks, question: "Observatory Circle resident; reclusive New Hampshire author; Tim Martin's pubs; Wardle and Makin's shops?", answer: "JD: JD Vance; JD Salinger; JD Wetherspoon; JD Sports", score: .half)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}

#Preview("Results view") {
    ZStack {
        ResultsView(score: 10.5)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
}
