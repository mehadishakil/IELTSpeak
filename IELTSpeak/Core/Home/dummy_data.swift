//
//  data.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

// dummy data
import Foundation

let testQuestions: [TestPart] = [
    TestPart(
        part: 1,
        title: "Introduction & Interview",
        duration: "4-5 minutes",
        questions: [
            "What's your full name?",
            "Where are you from?",
            "Do you work or study?",
            "Tell me about your hometown.",
            "What do you like most about your job/studies?"
        ]
    ),
    TestPart(
        part: 2,
        title: "Individual Long Turn",
        duration: "2-3 minutes",
        questions: [
            "Describe a memorable journey you have taken. You should say:\n• Where you went\n• Who you went with\n• What you did there\n• And explain why it was memorable"
        ]
    ),
    TestPart(
        part: 3,
        title: "Two-way Discussion",
        duration: "4-5 minutes",
        questions: [
            "How has travel changed in your country over the past decades?",
            "What are the benefits of traveling to different countries?",
            "Do you think virtual reality will replace real travel in the future?",
            "How important is it for young people to travel?"
        ]
    )
]

let testResults = [
    TestResult(
        id: "1",
        date: Date().addingTimeInterval(-86400 * 2),
        bandScore: 7.5,
        duration: "14 min",
        parts: [6.5, 7.5, 8.0],
        overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive, and you demonstrated good grammatical accuracy. Work on reducing minor hesitations in Part 1.",
        conversations: [
            Conversation(
                part: 1,
                question: "Tell me about your hometown.",
                answer: "I come from a small town called Sylhet in Bangladesh. It's a beatiful place with lots of green hills and tea gardens. The people there are very friendly and hospitable. I've been living there for most of my life, and I really love the peaceful atmosphere.",
                errors: [
                    ConversationError(word: "beatiful", correction: "beautiful", range: NSRange(location: 68, length: 8))
                ]
            ),
            Conversation(
                part: 2,
                question: "Describe a memorable journey you have taken.",
                answer: "I'd like to talk about a trip I took to the mountains last year. It was absolutely breathtaking experience. We hiked for about three hours through dense forests and rocky paths. The view from the top was incredible - we could see the entire valley below us. What made it even more special was that I went with my best friends, and we had such a great time together.",
                errors: [
                    ConversationError(word: "breathtaking", correction: "a breathtaking", range: NSRange(location: 75, length: 12))
                ]
            )
        ]
    ),
    TestResult(
        id: "2",
        date: Date().addingTimeInterval(-86400 * 5),
        bandScore: 6.5,
        duration: "12 min",
        parts: [6.0, 7.0, 6.5],
        overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
        conversations: [
            Conversation(
                part: 1,
                question: "What do you do for work or study?",
                answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                errors: [
                    ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                ]
            )
        ]
    ),
    TestResult(
        id: "3",
        date: Date().addingTimeInterval(-86400 * 8),
        bandScore: 6.0,
        duration: "13 min",
        parts: [5.5, 6.0, 6.5],
        overallFeedback: "Adequate communication with some good ideas. Work on grammatical accuracy and expanding your range of vocabulary. Practice speaking more fluently without long pauses.",
        conversations: [
            Conversation(
                part: 1,
                question: "Do you like reading books?",
                answer: "Yes, I do like reading books very much. I usually read fiction books because they are very entertaining. My favorite author is J.K. Rowling, she wrote the Harry Potter series. I thinks reading is a good way to improve vocabulary and imagination.",
                errors: [
                    ConversationError(word: "thinks", correction: "think", range: NSRange(location: 156, length: 6))
                ]
            )
        ]
    ),
    TestResult(
        id: "4",
        date: Date().addingTimeInterval(-86400 * 5),
        bandScore: 6.5,
        duration: "12 min",
        parts: [6.0, 7.0, 6.5],
        overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
        conversations: [
            Conversation(
                part: 1,
                question: "What do you do for work or study?",
                answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                errors: [
                    ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                ]
            )
        ]
    ),
    TestResult(
        id: "5",
        date: Date().addingTimeInterval(-86400 * 5),
        bandScore: 6.5,
        duration: "12 min",
        parts: [6.0, 7.0, 6.5],
        overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
        conversations: [
            Conversation(
                part: 1,
                question: "What do you do for work or study?",
                answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                errors: [
                    ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                ]
            )
        ]
    ),
    TestResult(
        id: "6",
        date: Date().addingTimeInterval(-86400 * 5),
        bandScore: 6.5,
        duration: "12 min",
        parts: [6.0, 7.0, 6.5],
        overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
        conversations: [
            Conversation(
                part: 1,
                question: "What do you do for work or study?",
                answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                errors: [
                    ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                ]
            )
        ]
    ),
]
