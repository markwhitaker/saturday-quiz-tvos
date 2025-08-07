//
//  SaturdayQuizApp.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//  Updated to trigger build on 07/08/2025.
//

import SwiftUI

@main
struct SaturdayQuizApp: App {
    var body: some Scene {
        WindowGroup {
            QuizView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    exit(0)
                }
        }
    }
}
