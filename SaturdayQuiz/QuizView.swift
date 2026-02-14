//
//  ContentView.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct FontSizes {
    static let title: CGFloat = 120
    static let body: CGFloat = 70
    static let whatLinks: CGFloat = 35
    static let subTitle: CGFloat = 50
}

struct FontWeights {
    static let title: Font.Weight = .light
    static let subTitle: Font.Weight = .regular
    static let body: Font.Weight = .light
    static let whatLinks: Font.Weight = .bold
    static let scoreTick: Font.Weight = .heavy
}

struct Dimensions {
    static let numberWidth: CGFloat = 150
    static let gridSpacing: CGFloat = 20
    static let outerSpacing: CGFloat = 40
    static let scoreCircle: CGFloat = 100
    static let scoreTick: CGFloat = 50
    static let scoreCircleBorder: CGFloat = 3
    static let whatLinksSpacing: CGFloat = 10
    static let qrCodeSize: CGFloat = 200
}

struct Colors {
    static let text = try! Color.fromHex("ddd")
    static let highlight = try! Color.fromHex("fd0")
    static let midGray = try! Color.fromHex("666")
    static let darkGray = try! Color.fromHex("444")
}

struct Constants {
    static let fontFace = "Open Sans"
}

struct QuizView: View {
    @StateObject var presenter = QuizPresenter()

    @FocusState private var isFocused: Bool
    
    private let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter
    }()

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
                    QuestionView(
                        number: number,
                        type: type,
                        question: question)
                case .answersTitle:
                    AnswersTitleView()
                case .questionAnswer(let number, let type, let question, let answer):
                    QuestionView(
                        number: number,
                        type: type,
                        question: question,
                        answer: answer,
                        score: presenter.scores[number - 1])
                case .results:
                    ResultsView(score: presenter.totalScore, scores: presenter.scores)
                }
            }
            .foregroundStyle(Colors.text)
            .fillParentTopLeft()
        }
        .fillParentTopLeft()
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
            presenter.cycleScore()
        }
        .onPlayPauseCommand {
            presenter.cycleScore()
        }
    }
}

struct LoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
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
        .fillParentCentered()
    }
}

struct ReadyView: View {
    let date: String
    
    init(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        self.date = dateFormatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Text(date)
                .font(.custom(Constants.fontFace, size: FontSizes.subTitle))
                .fontWeight(FontWeights.subTitle)
                .foregroundColor(Colors.highlight)
                .padding(.bottom, 400)
                .textCase(.uppercase)
            
            Text("Ready?")
                .font(.custom(Constants.fontFace, size: FontSizes.title))
                .fontWeight(FontWeights.title)
                .foregroundColor(Colors.text)
        }
        .fillParentCentered()
    }
}

struct QuestionView: View {
    let number: Int
    let isWhatLinks: Bool
    let question: String
    let answer: String?
    let score: ScoreState?

    init(number: Int, type: QuestionType, question: String) {
        self.number = number
        self.question = question
        self.answer = nil
        self.score = nil
        self.isWhatLinks = type == .whatLinks

    }

    init(number: Int, type: QuestionType, question: String, answer: String, score: ScoreState) {
        self.number = number
        self.question = question
        self.answer = answer
        self.score = score
        self.isWhatLinks = type == .whatLinks
    }
    
    var body: some View {
        ZStack {
            Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: Dimensions.gridSpacing) {
                GridRow {
                    Color.clear.frame(width: 0, height: 0)
                    HStack(spacing: Dimensions.whatLinksSpacing) {
                        Image(systemName: "link")
                        Text("What links")
                            .textCase(.uppercase)
                    }
                    .font(.custom(Constants.fontFace, size: FontSizes.whatLinks))
                    .fontWeight(FontWeights.whatLinks)
                    .foregroundStyle(Colors.midGray)
                    .opacity(isWhatLinks ? 1 : 0)
                }

                GridRow {
                    Text("\(number).")
                        .frame(width: Dimensions.numberWidth, alignment: .topLeading)
                    Text(question)
                }
                .font(.custom(Constants.fontFace, size: FontSizes.body))
                .fontWeight(FontWeights.body)
                .foregroundStyle(Colors.text)

                if (answer != nil) {
                    GridRow {
                        Color.clear.frame(width: 0, height: 0)
                        Text(answer!)
                    }
                    .font(.custom(Constants.fontFace, size: FontSizes.body))
                    .fontWeight(FontWeights.body)
                    .foregroundStyle(Colors.highlight)
                }
            }
            .fillParentTopLeft()

            if (score != nil) {
                ZStack {
                    ScoreIndicatorView(score: score!)
                }
                .fillParentBottomLeft()
            }
        }
        .fillParentTopLeft()
        .padding(Dimensions.outerSpacing)
    }
}

struct AnswersTitleView: View {
    var body: some View {
        ZStack {
            Text("Answers")
                .font(.custom(Constants.fontFace, size: FontSizes.title))
                .fontWeight(FontWeights.title)
                .foregroundColor(Colors.text)
        }
        .fillParentCentered()
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
                    .font(.system(size: Dimensions.scoreTick, weight: FontWeights.scoreTick))
                    .foregroundColor(.black)
            case .half:
                Circle()
                    .stroke(Colors.darkGray, lineWidth: Dimensions.scoreCircleBorder)
                    .frame(width: Dimensions.scoreCircle, height: Dimensions.scoreCircle)
                Image(systemName: "checkmark")
                    .font(.system(size: Dimensions.scoreTick, weight: FontWeights.scoreTick))
                    .foregroundColor(Colors.highlight)
            }
        }
    }
}

struct ResultsView: View {
    let scoreString: String
    let qrText: String
    let scores: [ScoreState]
    
    init(score: Double, scores: [ScoreState]) {
        self.scores = scores
        self.scoreString = ScoreFormatter.formatScore(score)
        self.qrText = ScoreFormatter.qrPayload(score: score, scores: scores)
    }
    
    var body: some View {
        ZStack {
            Text("End")
                .font(.custom(Constants.fontFace, size: FontSizes.title))
                .fontWeight(FontWeights.title)
                .foregroundColor(Colors.text)

            Text("Total score: \(scoreString)")
                .font(.custom(Constants.fontFace, size: FontSizes.subTitle))
                .fontWeight(FontWeights.subTitle)
                .foregroundColor(Colors.highlight)
                .padding(.top, 400)
                .textCase(.uppercase)
            
            QRCodeView(text: qrText)
                .frame(width: Dimensions.qrCodeSize, height: Dimensions.qrCodeSize)
                .padding(.trailing, Dimensions.outerSpacing)
                .padding(.bottom, Dimensions.outerSpacing)
                .fillParentBottomRight()
        }
        .fillParentCentered()
    }
}

struct QRCodeView: View {
    let text: String

    var body: some View {
        if let image = QrCodeGenerator().generateQRCode(from: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
    }
}

#Preview("Loading view") {
    ZStack {
        LoadingView()
    }
    .fillParentTopLeft()
}

#Preview("Ready view") {
    ZStack {
        ReadyView(date: Date())
    }
    .fillParentTopLeft()
}

#Preview("Question view: normal") {
    ZStack {
        QuestionView(number: 4, type: .normal, question: "Which sci-fi writer was the first person in Europe to buy a Mac computer?")
    }
    .fillParentTopLeft()
}

#Preview("Question view: what links") {
    ZStack {
        QuestionView(number: 10, type: .whatLinks, question: "Observatory Circle resident; reclusive New Hampshire author; Tim Martin's pubs; Wardle and Makin's shops?")
    }
    .fillParentTopLeft()
}

#Preview("Answers title view") {
    ZStack {
        AnswersTitleView()
    }
    .fillParentTopLeft()
}

#Preview("Question/answer view: normal") {
    ZStack {
        QuestionView(number: 4, type: .normal, question: "Which sci-fi writer was the first person in Europe to buy a Mac computer?", answer: "Douglas Adams (Stephen Fry was the second)", score: .full)
    }
    .fillParentTopLeft()
}

#Preview("Question/answer view: what links") {
    ZStack {
        QuestionView(number: 10, type: .whatLinks, question: "Star patterns; time travel in Hill Valley; piano; neo-Nazi code? also some other rather long-winded things going all around the houses to push this out to multiple lines", answer: "88: 88 constellations recognised by the International Astronomical Union; DeLorean’s 88mph in Back to the Future; 88 keys; numerical code for “Heil Hitler”", score: .half)
    }
    .fillParentTopLeft()
}

#Preview("Results view") {
    ZStack {
        ResultsView(score: 10.5, scores: [.full, .full, .full, .full, .full, .full, .full, .full, .full, .full, .half, .none, .none, .none, .none])
    }
    .fillParentTopLeft()
}

