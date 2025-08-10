import SwiftUI

struct GrammarTopic {
    let title: String
    let rule: String
    let patterns: [String]
    let examQuestion: String
    let badExample: String
    let goodExample: String
    let highlightedText: String
}

struct GrammarTopicView: View {
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    let grammarTopics = [
        GrammarTopic(
            title: "Past Perfect",
            rule: "Use Past Perfect to show something happened before another event in the past.",
            patterns: ["had + past participle", "hadn't + past participle"],
            examQuestion: "Tell me about a trip you took.",
            badExample: "I go to Paris last year.",
            goodExample: "I had never been abroad before I went to Paris last year.",
            highlightedText: "had never been abroad"
        ),
        GrammarTopic(
            title: "Present Perfect Continuous",
            rule: "Use Present Perfect Continuous to show ongoing actions that started in the past and continue to now.",
            patterns: ["have/has + been + -ing", "haven't/hasn't + been + -ing"],
            examQuestion: "How long have you been studying English?",
            badExample: "I study English for 3 years.",
            goodExample: "I have been studying English for 3 years.",
            highlightedText: "have been studying"
        ),
        GrammarTopic(
            title: "Future Perfect",
            rule: "Use Future Perfect to show something will be completed before a specific time in the future.",
            patterns: ["will have + past participle", "won't have + past participle"],
            examQuestion: "What are your plans for next year?",
            badExample: "I finish my degree next summer.",
            goodExample: "I will have finished my degree by next summer.",
            highlightedText: "will have finished"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressIndicator
                cardStack
                navigationButtons
            }
            .navigationTitle("Grammar Topics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var progressIndicator: some View {
        HStack {
            ForEach(0..<grammarTopics.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .padding(.top, 8)
    }
    
    private var cardStack: some View {
        ZStack {
            ForEach(Array(grammarTopics.enumerated()), id: \.offset) { index, topic in
                if index >= currentIndex {
                    GrammarCardView(topic: topic)
                        .scaleEffect(index == currentIndex ? 1.0 : 0.95)
                        .offset(
                            x: index == currentIndex ? dragOffset : CGFloat(index - currentIndex) * 20,
                            y: CGFloat(index - currentIndex) * 10
                        )
                        .opacity(index == currentIndex ? 1.0 : (index == currentIndex + 1 ? 0.7 : 0.4))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                        .zIndex(Double(grammarTopics.count - index))
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        if value.translation.width < -100 && currentIndex < grammarTopics.count - 1 {
                            currentIndex += 1
                        } else if value.translation.width > 100 && currentIndex > 0 {
                            currentIndex -= 1
                        }
                        dragOffset = 0
                    }
                }
        )
        .padding(.top, 16)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                withAnimation(.spring()) {
                    if currentIndex > 0 {
                        currentIndex -= 1
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(currentIndex > 0 ? .blue : .gray)
                    .padding()
            }
            .disabled(currentIndex == 0)
            
            Spacer()
            
            Text("\(currentIndex + 1) of \(grammarTopics.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    if currentIndex < grammarTopics.count - 1 {
                        currentIndex += 1
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(currentIndex < grammarTopics.count - 1 ? .blue : .gray)
                    .padding()
            }
            .disabled(currentIndex == grammarTopics.count - 1)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct GrammarCardView: View {
    let topic: GrammarTopic
    
    private var highlightedExampleText: some View {
        let goodText = topic.goodExample
        let highlightRange = goodText.range(of: topic.highlightedText)
        
        let textView: Text
        
        if let range = highlightRange {
            let attributedString = NSMutableAttributedString(string: goodText)
            let nsRange = NSRange(range, in: goodText)
            attributedString.addAttribute(.backgroundColor, value: UIColor.yellow.withAlphaComponent(0.3), range: nsRange)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)
            
            textView = Text(AttributedString(attributedString))
        } else {
            textView = Text(goodText)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        
        return textView
            .lineLimit(nil)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green.opacity(0.1))
            )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(topic.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Divider()
            }
            
            // Part 1: Quick Rule Summary
            VStack(alignment: .leading, spacing: 12) {
                Label("Quick Rule Summary", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rule:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(topic.rule)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Patterns:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(topic.patterns, id: \.self) { pattern in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                            Text(pattern)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
            )
            
            // Part 2: IELTS-Specific Examples
            VStack(alignment: .leading, spacing: 12) {
                Label("IELTS Examples", systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Exam Question
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exam Question:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("\(topic.examQuestion)")
                            .font(.body)
                            .italic()
                            .foregroundColor(.primary)
                            .lineLimit(nil)
                    }
                    
                    // Bad Example
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Bad:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        
                        Text(topic.badExample)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(nil)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    
                    // Good Example
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Good:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        // Create highlighted text
                        highlightedExampleText
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct GrammarTopicView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GrammarTopicView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            GrammarTopicView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            // Individual card preview
            GrammarCardView(topic: GrammarTopic(
                title: "Past Perfect",
                rule: "Use Past Perfect to show something happened before another event in the past.",
                patterns: ["had + past participle", "hadn't + past participle"],
                examQuestion: "Tell me about a trip you took.",
                badExample: "I go to Paris last year.",
                goodExample: "I had never been abroad before I went to Paris last year.",
                highlightedText: "had never been abroad"
            ))
            .previewDisplayName("Single Card")
        }
    }
}
