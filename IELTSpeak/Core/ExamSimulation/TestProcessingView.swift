//
//  TestProcessingView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

struct TestProcessingView: View {
    @Binding var isProcessing: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            ProcessingAnimation(isProcessing: isProcessing)
            ProcessingSteps()
            Spacer()
        }
        .padding(.top, 50)
    }
}

struct ProcessingAnimation: View {
    let isProcessing: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(isProcessing ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isProcessing)
                
                Image(systemName: "brain.head.profile")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            Text("Processing Your Test")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Our AI is analyzing your responses and preparing detailed feedback...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct ProcessingSteps: View {
    var body: some View {
        VStack(spacing: 16) {
            ProcessingStep(title: "Analyzing Speech Quality", isCompleted: true)
            ProcessingStep(title: "Evaluating Fluency & Coherence", isCompleted: true)
            ProcessingStep(title: "Checking Grammar & Vocabulary", isCompleted: false)
            ProcessingStep(title: "Generating Feedback", isCompleted: false)
        }
        .padding(.horizontal, 20)
    }
}

struct ProcessingStep: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .gray)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
