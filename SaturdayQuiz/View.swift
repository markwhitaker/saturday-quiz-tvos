//
//  View.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 14/06/2025.
//


import SwiftUI

extension View {
    func fillParentCentered() -> some View {
        return self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    func fillParentTopLeft() -> some View {
        return self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}