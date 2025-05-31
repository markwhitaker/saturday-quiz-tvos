//
//  ContentView.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

enum QuestionType: String, Decodable {
    case normal = "NORMAL"
    case whatLinks = "WHAT_LINKS"
}

struct QuizQuestion: Decodable {
    let number: Int
    let question: String
    let answer: String
    let type: QuestionType
    let whatLinks: [String]
}

struct Quiz: Decodable {
    let id: String
    let date: Date
    let title: String
    let questions: [QuizQuestion]
}

struct ContentView: View {
    @State private var quiz: Quiz?
    
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
            if let quiz = quiz {
                Text(quiz.title)
                    .font(.title2)
                    .padding()
            }
        }
        .padding()
        .onAppear(perform: fetchQuiz)
    }
    
    func fetchQuiz() {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Fetch error:", error ?? "Unknown error")
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let decoded = try jsonDecoder.decode(Quiz.self, from: data)
                DispatchQueue.main.async {
                    quiz = decoded
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
