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
            "What do you like most about your job/studies?",
            "Let's talk about hobbies. What do you do in your free time?",
            "Do you prefer indoor or outdoor activities?"
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
            "How important is it for young people to travel?",
            "Let's discuss the environmental impact of tourism. What are your thoughts?",
            "How can governments and individuals promote sustainable tourism?"
        ]
    )
]

let testResults: [TestResult] = [
    TestResult(
        id: "1",
        date: Date().addingTimeInterval(-86400 * 2),
        bandScore: 7.0,
        duration: "14 min",
        criteriaScores: [
            "Fluency and coherence": 6.5,
            "Lexical resource": 7.5,
            "Grammatical range and accuracy": 8.0,
            "Pronunciation": 7.0
        ],
        overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive, and you demonstrated good grammatical accuracy. Work on reducing minor hesitations in Part 1.",
        conversations: [
                    Conversation(
                        part: 1,
                        order: 1,
                        question: "What's your full name?",
                        answer: "My full name is John Smith.",
                        errors: []
                    ),
                    Conversation(
                        part: 1,
                        order: 2,
                        question: "Where are you from?",
                        answer: "I come from a small town called Sylhet in Bangladesh. It's a beatiful place with lots of green hills and tea gardens. The people there are very friendly and hospitable. I've been living there for most of my life, and I really love the peaceful atmosphere.",
                        errors: [
                            ConversationError(word: "beatiful", correction: "beautiful", range: NSRange(location: 68, length: 8))
                        ]
                    ),
                    Conversation(
                        part: 1,
                        order: 3,
                        question: "Do you work or study?",
                        answer: "Currently, I am studying at the University of Dhaka. I am pursuing a Bachelor's degree in Computer Science. I am in my third year.",
                        errors: []
                    ),
                    Conversation(
                        part: 2,
                        order: 1,
                        question: "Describe a memorable journey you have taken. You should say:\n• Where you went\n• Who you went with\n• What you did there\n• And explain why it was memorable",
                        answer: "I'd like to talk about a trip I took to the mountains last year. It was absolutely breathtaking experience. We hiked for about three hours through dense forests and rocky paths. The view from the top was incredible - we could see the entire valley below us. What made it even more special was that I went with my best friends, and we had such a great time together.",
                        errors: [
                            ConversationError(word: "breathtaking", correction: "a breathtaking", range: NSRange(location: 75, length: 12)) // Assuming the word 'experience' follows 'breathtaking' immediately. Adjust range if needed.
                        ]
                    ),
                    Conversation(
                        part: 3,
                        order: 1,
                        question: "How has travel changed in your country over the past decades?",
                        answer: "Travel has changed significantly over the past few decades. Previously, it was often restricted to the wealthy, and destinations were limited. Now, with the advent of low-cost airlines and improved infrastructure, traveling has become much more accessible to the average person. Also, the Internet plays a huge role in planning and booking trips.",
                        errors: []
                    ),
                    Conversation(
                        part: 3,
                        order: 2,
                        question: "What are the benefits of traveling to different countries?",
                        answer: "There are numerous benefits to traveling abroad. Firstly, it broadens your perspective and allows you to experience diverse cultures and ways of life. Secondly, it helps you develop independence and problem-solving skills. Additionally, it's a great opportunity to learn new languages and meet people from different backgrounds.",
                        errors: []
                    )
                ]
    ),
    TestResult(
        id: "2",
        date: Date().addingTimeInterval(-86400 * 5),
        bandScore: 6.5,
        duration: "12 min",
        criteriaScores: [
            "Fluency and coherence": 6.0,
            "Lexical resource": 7.0,
            "Grammatical range and accuracy": 6.5,
            "Pronunciation": 6.0
        ],
        overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
        conversations: [
                    Conversation(
                        part: 1,
                        order: 1,
                        question: "What do you do for work or study?",
                        answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                        errors: [
                            ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                        ]
                    ),
                    Conversation(
                        part: 1,
                        order: 2,
                        question: "Tell me about your hometown.",
                        answer: "My hometown is a busy city. It have many tall building and a lot of traffic. I like the food there, but I don't like the noise.",
                        errors: [
                            ConversationError(word: "have", correction: "has", range: NSRange(location: 27, length: 4)),
                            ConversationError(word: "building", correction: "buildings", range: NSRange(location: 40, length: 8))
                        ]
                    ),
                    Conversation(
                        part: 2,
                        order: 1,
                        question: "Describe a memorable journey you have taken.",
                        answer: "I went to a beach last summer. It was very hot. I swam in the sea and ate ice cream. My friends was there too. We had a good time.",
                        errors: [
                            ConversationError(word: "was", correction: "were", range: NSRange(location: 78, length: 3))
                        ]
                    ),
                    Conversation(
                        part: 3,
                        order: 1,
                        question: "Do you think virtual reality will replace real travel in the future?",
                        answer: "I don't think so. Virtual reality is good, but it can't replace the real feeling of being in a new place. You can't smell the food or feel the air. Real travel is better.",
                        errors: []
                    )
                ]
    ),
    TestResult(
        id: "3",
        date: Date().addingTimeInterval(-86400 * 8),
        bandScore: 6.0,
        duration: "13 min",
        criteriaScores: [
            "Fluency and coherence": 5.5,
            "Lexical resource": 6.0,
            "Grammatical range and accuracy": 6.5,
            "Pronunciation": 6.0
        ],
        overallFeedback: "Adequate communication with some good ideas. Work on grammatical accuracy and expanding your range of vocabulary. Practice speaking more fluently without long pauses.",
        conversations: [
                    Conversation(
                        part: 1,
                        order: 1,
                        question: "Do you like reading books?",
                        answer: "Yes, I do like reading books very much. I usually read fiction books because they are very entertaining. My favorite author is J.K. Rowling, she wrote the Harry Potter series. I thinks reading is a good way to improve vocabulary and imagination.",
                        errors: [
                            ConversationError(word: "thinks", correction: "think", range: NSRange(location: 156, length: 6))
                        ]
                    ),
                    Conversation(
                        part: 1,
                        order: 2,
                        question: "What do you do in your free time?",
                        answer: "In my free time, I like to playing video games and watching movies. Sometimes I go out with my friends. It is a good way to relax.",
                        errors: [
                            ConversationError(word: "playing", correction: "play", range: NSRange(location: 28, length: 7))
                        ]
                    ),
                    Conversation(
                        part: 3,
                        order: 1,
                        question: "How important is it for young people to travel?",
                        answer: "It's very important for young people to travel. It helps them to learn about different cultures and become more open-minded. They can also gain independence and valuable life experience. It is a good opportunity for person to grow.",
                        errors: [
                            ConversationError(word: "person", correction: "a person", range: NSRange(location: 191, length: 6))
                        ]
                    )
                ]
    ),
    TestResult(
        id: "4",
        date: Date().addingTimeInterval(-86400 * 10),
        bandScore: 5.5,
        duration: "11 min",
        criteriaScores: [
            "Fluency and coherence": 5.0,
            "Lexical resource": 5.5,
            "Grammatical range and accuracy": 5.5,
            "Pronunciation": 6.0
        ],
        overallFeedback: "Needs improvement in grammar and vocabulary. Try to use more complex sentence structures. Focus on reducing pauses and improving flow.",
        conversations: [
                    Conversation(
                        part: 1,
                        order: 1,
                        question: "What's your full name?",
                        answer: "My name is Alisa.",
                        errors: []
                    ),
                    Conversation(
                        part: 1,
                        order: 2,
                        question: "Where are you from?",
                        answer: "I am from a small village. There is not much there. Just some shops.",
                        errors: []
                    ),
                    Conversation(
                        part: 1,
                        order: 3,
                        question: "Do you prefer indoor or outdoor activities?",
                        answer: "I prefer outdoor activities. I like to running outside and play sports. It is more healthy.",
                        errors: [
                            ConversationError(word: "running", correction: "run", range: NSRange(location: 43, length: 7)),
                            ConversationError(word: "healthy", correction: "healthier", range: NSRange(location: 81, length: 7))
                        ]
                    ),
                    Conversation(
                        part: 3,
                        order: 1,
                        question: "Let's discuss the environmental impact of tourism. What are your thoughts?",
                        answer: "Tourism can make bad for environment. Many rubbish is left and pollution from cars. We need to be careful.",
                        errors: [
                            ConversationError(word: "make bad", correction: "be bad", range: NSRange(location: 15, length: 8)),
                            ConversationError(word: "Many rubbish is left", correction: "Much rubbish is left", range: NSRange(location: 32, length: 20))
                        ]
                    )
                ]
    ),
    TestResult(
        id: "5",
        date: Date().addingTimeInterval(-86400 * 15),
        bandScore: 7.8,
        duration: "15 min",
        criteriaScores: [
            "Fluency and coherence": 7.5,
            "Lexical resource": 8.0,
            "Grammatical range and accuracy": 8.0,
            "Pronunciation": 7.5
        ],
        overallFeedback: "Outstanding performance across all criteria. Your command of English is excellent, with highly articulate responses and a wide range of vocabulary. Maintain this level of accuracy and fluency.",
        conversations: [
                    Conversation(
                        part: 1,
                        order: 1,
                        question: "Tell me about your hometown.",
                        answer: "My hometown is a vibrant metropolis, a bustling hub of commerce and culture. It's renowned for its historical landmarks and diverse culinary scene. The energy of the city is truly infectious, and I appreciate the endless opportunities it presents for both personal and professional growth.",
                        errors: []
                    ),
                    Conversation(
                        part: 1,
                        order: 2,
                        question: "What do you like most about your job/studies?",
                        answer: "What I find most gratifying about my studies is the opportunity for intellectual exploration and the challenge of delving into complex problem sets. The collaborative environment also fosters a sense of camaraderie, which makes the learning process even more enjoyable.",
                        errors: []
                    ),
                    Conversation(
                        part: 2,
                        order: 1,
                        question: "Describe a memorable journey you have taken.",
                        answer: "One truly unforgettable journey I embarked upon was an expedition to the Amazon rainforest. The sheer biodiversity was awe-inspiring; every turn presented a new marvel of nature. Navigating the tributaries by canoe and encountering indigenous communities provided an unparalleled insight into a world far removed from urban civilization. It was a profound and transformative experience.",
                        errors: []
                    ),
                    Conversation(
                        part: 3,
                        order: 1,
                        question: "How can governments and individuals promote sustainable tourism?",
                        answer: "Promoting sustainable tourism requires a multifaceted approach involving both governmental policies and individual responsibility. Governments can implement stricter regulations on waste management and carbon emissions, invest in eco-friendly infrastructure, and offer incentives for sustainable businesses. Individually, tourists should engage in responsible practices like minimizing their environmental footprint, respecting local cultures, and supporting local economies.",
                        errors: []
                    ),
                    Conversation(
                        part: 3,
                        order: 2,
                        question: "Let's discuss the environmental impact of tourism. What are your thoughts?",
                        answer: "Tourism, while economically beneficial, undeniably carries significant environmental repercussions. These range from increased carbon emissions due to air travel and transportation, to excessive waste generation, and habitat destruction caused by overdevelopment. There's also the challenge of preserving fragile ecosystems from the sheer volume of visitors. It's a delicate balance between economic growth and ecological preservation.",
                        errors: [
                            ConversationError(word: "repercussions", correction: "impacts", range: NSRange(location: 78, length: 13)) // Example of suggesting a more common word
                        ]
                    )
                ]
    )
]
