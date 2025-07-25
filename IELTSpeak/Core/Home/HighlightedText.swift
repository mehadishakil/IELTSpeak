//
//  HighlightedText.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let errors: [ConversationError]
    
    var body: some View {
        Text(attributedString)
            .font(.body)
            .fontDesign(.rounded)
            .lineSpacing(4)
    }
    
    private var attributedString: AttributedString {
        var attributed = AttributedString(text)
        
        for error in errors {
            let startIndex = attributed.index(attributed.startIndex, offsetByCharacters: error.range.location)
            let endIndex = attributed.index(startIndex, offsetByCharacters: error.range.length)

            
            attributed[startIndex..<endIndex].foregroundColor = .red
            attributed[startIndex..<endIndex].backgroundColor = .red.opacity(0.2)
        }
        
        return attributed
    }
}
