//
//  BandDescriptor.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 25/7/25.
//

//
//import SwiftUI
//
//struct BandDescriptor {
//    let band: Int
//    let fluencyAndCoherence: String
//    let lexicalResource: String
//    let grammaticalRangeAndAccuracy: String
//    let pronunciation: String
//}
//
//struct IELTSSpeakingBandDescriptorsView: View {
//    @State private var selectedBand: Int = 9
//    @State private var selectedCriteria: String = "Fluency and Coherence"
//    
//    private let criteria = [
//        "Fluency and Coherence",
//        "Lexical Resource",
//        "Grammatical Range and Accuracy",
//        "Pronunciation"
//    ]
//    
//    private let bandDescriptors: [BandDescriptor] = [
//        BandDescriptor(
//            band: 9,
//            fluencyAndCoherence: "Fluent with only very occasional repetition or self-correction.\n\nAny hesitation that occurs is used only to prepare the content of the next utterance and not to find words or grammar.\n\nSpeech is situationally appropriate and cohesive features are fully acceptable.\n\nTopic development is fully coherent and appropriately extended.",
//            lexicalResource: "Total flexibility and precise use in all contexts.\n\nSustained use of accurate and idiomatic language.",
//            grammaticalRangeAndAccuracy: "Structures are precise and accurate at all times, apart from 'mistakes' characteristic of native speaker speech.",
//            pronunciation: "Uses a full range of phonological features to convey precise and/or subtle meaning.\n\nFlexible use of features of connected speech is sustained throughout.\n\nCan be effortlessly understood throughout.\n\nAccent has no effect on intelligibility."
//        ),
//        BandDescriptor(
//            band: 8,
//            fluencyAndCoherence: "Fluent with only very occasional repetition or self-correction.\n\nHesitation may occasionally be used to find words or grammar, but most will be content related.\n\nTopic development is coherent, appropriate and relevant.",
//            lexicalResource: "Wide resource, readily and flexibly used to discuss all topics and convey precise meaning.\n\nSkilful use of less common and idiomatic items despite occasional inaccuracies in word choice and collocation.\n\nEffective use of paraphrase as required.",
//            grammaticalRangeAndAccuracy: "Wide range of structures, flexibly used.\n\nThe majority of sentences are error free.\n\nOccasional inappropriacies and non-systematic errors occur. A few basic errors may persist.",
//            pronunciation: "Uses a wide range of phonological features to convey precise and/or subtle meaning.\n\nCan sustain appropriate rhythm. Flexible use of stress and intonation across long utterances, despite occasional lapses.\n\nCan be easily understood throughout.\n\nAccent has minimal effect on intelligibility."
//        ),
//        BandDescriptor(
//            band: 7,
//            fluencyAndCoherence: "Able to keep going and readily produce long turns without noticeable effort.\n\nSome hesitation, repetition and/or self-correction may occur, often mid-sentence and indicate problems with accessing appropriate language. However, these will not affect coherence.\n\nFlexible use of spoken discourse markers, connectives and cohesive features.",
//            lexicalResource: "Resource flexibly used to discuss a variety of topics.\n\nSome ability to use less common and idiomatic items and an awareness of style and collocation is evident though inappropriacies occur.\n\nEffective use of paraphrase as required.",
//            grammaticalRangeAndAccuracy: "A range of structures flexibly used. Error-free sentences are frequent.\n\nBoth simple and complex sentences are used effectively despite some errors. A few basic errors persist.",
//            pronunciation: "Displays all the positive features of band 6, and some, but not all, of the positive features of band 8."
//        ),
//        BandDescriptor(
//            band: 6,
//            fluencyAndCoherence: "Able to keep going and demonstrates a willingness to produce long turns.\n\nCoherence may be lost at times as a result of hesitation, repetition and/or self-correction.\n\nUses a range of spoken discourse markers, connectives and cohesive features though not always appropriately.",
//            lexicalResource: "Resource sufficient to discuss topics at length.\n\nVocabulary use may be inappropriate but meaning is clear.\n\nGenerally able to paraphrase successfully.",
//            grammaticalRangeAndAccuracy: "Produces a mix of short and complex sentence forms and a variety of structures with limited flexibility.\n\nThough errors frequently occur in complex structures, these rarely impede communication.",
//            pronunciation: "Uses a range of phonological features, but control is variable.\n\nChunking is generally appropriate, but rhythm may be affected by a lack of stress-timing and/or a rapid speech rate.\n\nSome effective use of intonation and stress, but this is not sustained.\n\nIndividual words or phonemes may be mispronounced but this causes only occasional lack of clarity.\n\nCan generally be understood throughout without much effort."
//        ),
//        BandDescriptor(
//            band: 5,
//            fluencyAndCoherence: "Usually able to keep going, but relies on repetition and self-correction to do so and/or on slow speech.\n\nHesitations are often associated with mid-sentence searches for fairly basic lexis and grammar.\n\nOveruse of certain discourse markers, connectives and other cohesive features.\n\nMore complex speech usually causes disfluency but simpler language may be produced fluently.",
//            lexicalResource: "Resource sufficient to discuss familiar and unfamiliar topics but there is limited flexibility.\n\nAttempts paraphrase but not always with success.",
//            grammaticalRangeAndAccuracy: "Basic sentence forms are fairly well controlled for accuracy.\n\nComplex structures are attempted but these are limited in range, nearly always contain errors and may lead to the need for reformulation.",
//            pronunciation: "Displays all the positive features of band 4, and some, but not all, of the positive features of band 6."
//        ),
//        BandDescriptor(
//            band: 4,
//            fluencyAndCoherence: "Unable to keep going without noticeable pauses.\n\nSpeech may be slow with frequent repetition.\n\nOften self-corrects.\n\nCan link simple sentences but often with repetitious use of connectives.\n\nSome breakdowns in coherence.",
//            lexicalResource: "Resource sufficient for familiar topics but only basic meaning can be conveyed on unfamiliar topics.\n\nFrequent inappropriacies and errors in word choice.\n\nRarely attempts paraphrase.",
//            grammaticalRangeAndAccuracy: "Can produce basic sentence forms and some short utterances are error-free.\n\nSubordinate clauses are rare and, overall, turns are short, structures are repetitive and errors are frequent.",
//            pronunciation: "Uses some acceptable phonological features, but the range is limited.\n\nProduces some acceptable chunking, but there are frequent lapses in overall rhythm.\n\nAttempts to use intonation and stress, but control is limited.\n\nIndividual words or phonemes are frequently mispronounced, causing lack of clarity.\n\nUnderstanding requires some effort and there may be patches of speech that cannot be understood."
//        ),
//        BandDescriptor(
//            band: 3,
//            fluencyAndCoherence: "Frequent, sometimes long, pauses occur while candidate searches for words.\n\nLimited ability to link simple sentences and go beyond simple responses to questions.\n\nFrequently unable to convey basic message.",
//            lexicalResource: "Resource limited to simple vocabulary used primarily to convey personal information.\n\nVocabulary inadequate for unfamiliar topics.",
//            grammaticalRangeAndAccuracy: "Basic sentence forms are attempted but grammatical errors are numerous except in apparently memorised utterances.",
//            pronunciation: "Displays some features of band 2, and some, but not all, of the positive features of band 4."
//        ),
//        BandDescriptor(
//            band: 2,
//            fluencyAndCoherence: "Lengthy pauses before nearly every word.\n\nIsolated words may be recognisable but speech is of virtually no communicative significance.",
//            lexicalResource: "Very limited resource. Utterances consist of isolated words or memorised utterances.\n\nLittle communication possible without the support of mime or gesture.",
//            grammaticalRangeAndAccuracy: "No evidence of basic sentence forms.",
//            pronunciation: "Uses few acceptable phonological features (possibly because sample is insufficient).\n\nOverall problems with delivery impair attempts at connected speech.\n\nIndividual words and phonemes are mainly mispronounced and little meaning is conveyed.\n\nOften unintelligible."
//        ),
//        BandDescriptor(
//            band: 1,
//            fluencyAndCoherence: "Essentially none.\n\nSpeech is totally incoherent.",
//            lexicalResource: "No resource bar a few isolated words.\n\nNo communication possible.",
//            grammaticalRangeAndAccuracy: "No rateable language unless memorised.",
//            pronunciation: "Can produce occasional individual words and phonemes that are recognisable, but no overall meaning is conveyed.\n\nUnintelligible."
//        )
//    ]
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Header
//                VStack(spacing: 16) {
//                    Text("IELTS Speaking Band Descriptors")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                    
//                    Text("Official scoring criteria for Academic and General Training tests")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 16)
//                .background(Color(UIColor.secondarySystemBackground))
//                
//                // Band Selector
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 12) {
//                        ForEach(Array(bandDescriptors.enumerated()), id: \.offset) { index, descriptor in
//                            BandButton(
//                                band: descriptor.band,
//                                isSelected: selectedBand == descriptor.band
//                            ) {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    selectedBand = descriptor.band
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                }
//                .padding(.vertical, 16)
//                .background(Color(UIColor.systemBackground))
//                
//                // Criteria Selector
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(criteria, id: \.self) { criterion in
//                            CriteriaButton(
//                                title: criterion,
//                                isSelected: selectedCriteria == criterion
//                            ) {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    selectedCriteria = criterion
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                }
//                .padding(.vertical, 12)
//                .background(Color(UIColor.secondarySystemBackground))
//                
//                // Content
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 16) {
//                        // Band Header
//                        HStack {
//                            Text("Band \(selectedBand)")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .foregroundColor(colorForBand(selectedBand))
//                            
//                            Spacer()
//                            
//                            Text(selectedCriteria)
//                                .font(.headline)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        // Description
//                        Text(getDescriptionForSelectedCriteria())
//                            .font(.body)
//                            .lineSpacing(4)
//                            .foregroundColor(.primary)
//                    }
//                    .padding(20)
//                }
//                .background(Color(UIColor.systemBackground))
//            }
//        }
//        .navigationBarHidden(true)
//    }
//    
//    private func getDescriptionForSelectedCriteria() -> String {
//        guard let descriptor = bandDescriptors.first(where: { $0.band == selectedBand }) else {
//            return ""
//        }
//        
//        switch selectedCriteria {
//        case "Fluency and Coherence":
//            return descriptor.fluencyAndCoherence
//        case "Lexical Resource":
//            return descriptor.lexicalResource
//        case "Grammatical Range and Accuracy":
//            return descriptor.grammaticalRangeAndAccuracy
//        case "Pronunciation":
//            return descriptor.pronunciation
//        default:
//            return ""
//        }
//    }
//    
//    private func colorForBand(_ band: Int) -> Color {
//        switch band {
//        case 9: return .green
//        case 8: return Color(red: 0.6, green: 0.8, blue: 0.2)
//        case 7: return .blue
//        case 6: return Color(red: 0.2, green: 0.6, blue: 0.8)
//        case 5: return .orange
//        case 4: return Color(red: 0.9, green: 0.6, blue: 0.2)
//        case 3: return .red
//        case 2: return Color(red: 0.8, green: 0.2, blue: 0.2)
//        case 1: return Color(red: 0.6, green: 0.1, blue: 0.1)
//        default: return .gray
//        }
//    }
//}
//
//struct BandButton: View {
//    let band: Int
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text("\(band)")
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundColor(isSelected ? .white : colorForBand(band))
//                .frame(width: 44, height: 44)
//                .background(
//                    Circle()
//                        .fill(isSelected ? colorForBand(band) : Color.clear)
//                        .overlay(
//                            Circle()
//                                .stroke(colorForBand(band), lineWidth: 2)
//                        )
//                )
//        }
//        .scaleEffect(isSelected ? 1.1 : 1.0)
//        .animation(.easeInOut(duration: 0.2), value: isSelected)
//    }
//    
//    private func colorForBand(_ band: Int) -> Color {
//        switch band {
//        case 9: return .green
//        case 8: return Color(red: 0.6, green: 0.8, blue: 0.2)
//        case 7: return .blue
//        case 6: return Color(red: 0.2, green: 0.6, blue: 0.8)
//        case 5: return .orange
//        case 4: return Color(red: 0.9, green: 0.6, blue: 0.2)
//        case 3: return .red
//        case 2: return Color(red: 0.8, green: 0.2, blue: 0.2)
//        case 1: return Color(red: 0.6, green: 0.1, blue: 0.1)
//        default: return .gray
//        }
//    }
//}
//
//struct CriteriaButton: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(isSelected ? .white : .primary)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(
//                    Capsule()
//                        .fill(isSelected ? Color.blue : Color(UIColor.tertiarySystemFill))
//                )
//        }
//        .animation(.easeInOut(duration: 0.2), value: isSelected)
//    }
//}
//
//// Preview
//struct IELTSSpeakingBandDescriptorsView_Previews: PreviewProvider {
//    static var previews: some View {
//        IELTSSpeakingBandDescriptorsView()
//    }
//}















//
//import SwiftUI
//
//// MARK: - Data Model
//struct BandDescriptor: Identifiable {
//    let id = UUID()
//    let band: String
//    let description: String
//}
//
//// MARK: - Sample Data
//let bandDescriptors: [BandDescriptor] = [
//    BandDescriptor(band: "Band 9", description: "Expert user: fully operational command of the language with only occasional unsystematic inaccuracies and inappropriacies."),
//    BandDescriptor(band: "Band 8", description: "Very good user: has fully operational command with only occasional unsystematic inaccuracies and inappropriacies."),
//    BandDescriptor(band: "Band 7", description: "Good user: has operational command of the language, though with occasional inaccuracies, inappropriacies and misunderstandings."),
//    BandDescriptor(band: "Band 6", description: "Competent user: has generally effective command of the language despite some inaccuracies, inappropriacies and misunderstandings."),
//    BandDescriptor(band: "Band 5", description: "Modest user: partial command of the language, coping with overall meaning in most situations, though likely to make many mistakes."),
//    BandDescriptor(band: "Band 4", description: "Limited user: basic competence is limited to familiar situations. Has frequent problems in understanding and expression."),
//    BandDescriptor(band: "Band 3", description: "Extremely limited user: conveys and understands only general meaning in very familiar situations. Frequent breakdowns in communication."),
//    BandDescriptor(band: "Band 2", description: "Intermittent user: no real communication is possible except for the most basic information using isolated words or short formulae."),
//    BandDescriptor(band: "Band 1", description: "Non-user: essentially has no ability to use the language beyond a few isolated words.")
//]
//
//// MARK: - Main View
//struct BandDescriptorsView: View {
//    @State private var expandedBand: UUID?
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//                    ForEach(bandDescriptors) { descriptor in
//                        BandDescriptorCard(descriptor: descriptor, isExpanded: expandedBand == descriptor.id)
//                            .onTapGesture {
//                                withAnimation {
//                                    expandedBand = (expandedBand == descriptor.id) ? nil : descriptor.id
//                                }
//                            }
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Band Descriptors")
//        }
//    }
//}
//
//// MARK: - Card View
//struct BandDescriptorCard: View {
//    let descriptor: BandDescriptor
//    let isExpanded: Bool
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(descriptor.band)
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                Spacer()
//                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                    .foregroundColor(.gray)
//            }
//
//            if isExpanded {
//                Text(descriptor.description)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .transition(.opacity.combined(with: .slide))
//            }
//        }
//        .padding()
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
//    }
//}
//
//#Preview {
//    BandDescriptorsView()
//}






import SwiftUI

struct BandDescriptor {
    let band: Int
    let fluencyAndCoherence: String
    let lexicalResource: String
    let grammaticalRangeAndAccuracy: String
    let pronunciation: String
}

struct IELTSSpeakingBandDescriptorsView: View {
    @State private var selectedBand: Int = 9
    @State private var selectedCriteria: String = "Fluency and Coherence"
    
    private let criteria = [
        "Fluency and Coherence",
        "Lexical Resource",
        "Grammatical Range and Accuracy",
        "Pronunciation"
    ]
    
    private let bandDescriptors: [BandDescriptor] = [
        BandDescriptor(
            band: 9,
            fluencyAndCoherence: "Fluent with only very occasional repetition or self-correction.\n\nAny hesitation that occurs is used only to prepare the content of the next utterance and not to find words or grammar.\n\nSpeech is situationally appropriate and cohesive features are fully acceptable.\n\nTopic development is fully coherent and appropriately extended.",
            lexicalResource: "Total flexibility and precise use in all contexts.\n\nSustained use of accurate and idiomatic language.",
            grammaticalRangeAndAccuracy: "Structures are precise and accurate at all times, apart from 'mistakes' characteristic of native speaker speech.",
            pronunciation: "Uses a full range of phonological features to convey precise and/or subtle meaning.\n\nFlexible use of features of connected speech is sustained throughout.\n\nCan be effortlessly understood throughout.\n\nAccent has no effect on intelligibility."
        ),
        BandDescriptor(
            band: 8,
            fluencyAndCoherence: "Fluent with only very occasional repetition or self-correction.\n\nHesitation may occasionally be used to find words or grammar, but most will be content related.\n\nTopic development is coherent, appropriate and relevant.",
            lexicalResource: "Wide resource, readily and flexibly used to discuss all topics and convey precise meaning.\n\nSkilful use of less common and idiomatic items despite occasional inaccuracies in word choice and collocation.\n\nEffective use of paraphrase as required.",
            grammaticalRangeAndAccuracy: "Wide range of structures, flexibly used.\n\nThe majority of sentences are error free.\n\nOccasional inappropriacies and non-systematic errors occur. A few basic errors may persist.",
            pronunciation: "Uses a wide range of phonological features to convey precise and/or subtle meaning.\n\nCan sustain appropriate rhythm. Flexible use of stress and intonation across long utterances, despite occasional lapses.\n\nCan be easily understood throughout.\n\nAccent has minimal effect on intelligibility."
        ),
        BandDescriptor(
            band: 7,
            fluencyAndCoherence: "Able to keep going and readily produce long turns without noticeable effort.\n\nSome hesitation, repetition and/or self-correction may occur, often mid-sentence and indicate problems with accessing appropriate language. However, these will not affect coherence.\n\nFlexible use of spoken discourse markers, connectives and cohesive features.",
            lexicalResource: "Resource flexibly used to discuss a variety of topics.\n\nSome ability to use less common and idiomatic items and an awareness of style and collocation is evident though inappropriacies occur.\n\nEffective use of paraphrase as required.",
            grammaticalRangeAndAccuracy: "A range of structures flexibly used. Error-free sentences are frequent.\n\nBoth simple and complex sentences are used effectively despite some errors. A few basic errors persist.",
            pronunciation: "Displays all the positive features of band 6, and some, but not all, of the positive features of band 8."
        ),
        BandDescriptor(
            band: 6,
            fluencyAndCoherence: "Able to keep going and demonstrates a willingness to produce long turns.\n\nCoherence may be lost at times as a result of hesitation, repetition and/or self-correction.\n\nUses a range of spoken discourse markers, connectives and cohesive features though not always appropriately.",
            lexicalResource: "Resource sufficient to discuss topics at length.\n\nVocabulary use may be inappropriate but meaning is clear.\n\nGenerally able to paraphrase successfully.",
            grammaticalRangeAndAccuracy: "Produces a mix of short and complex sentence forms and a variety of structures with limited flexibility.\n\nThough errors frequently occur in complex structures, these rarely impede communication.",
            pronunciation: "Uses a range of phonological features, but control is variable.\n\nChunking is generally appropriate, but rhythm may be affected by a lack of stress-timing and/or a rapid speech rate.\n\nSome effective use of intonation and stress, but this is not sustained.\n\nIndividual words or phonemes may be mispronounced but this causes only occasional lack of clarity.\n\nCan generally be understood throughout without much effort."
        ),
        BandDescriptor(
            band: 5,
            fluencyAndCoherence: "Usually able to keep going, but relies on repetition and self-correction to do so and/or on slow speech.\n\nHesitations are often associated with mid-sentence searches for fairly basic lexis and grammar.\n\nOveruse of certain discourse markers, connectives and other cohesive features.\n\nMore complex speech usually causes disfluency but simpler language may be produced fluently.",
            lexicalResource: "Resource sufficient to discuss familiar and unfamiliar topics but there is limited flexibility.\n\nAttempts paraphrase but not always with success.",
            grammaticalRangeAndAccuracy: "Basic sentence forms are fairly well controlled for accuracy.\n\nComplex structures are attempted but these are limited in range, nearly always contain errors and may lead to the need for reformulation.",
            pronunciation: "Displays all the positive features of band 4, and some, but not all, of the positive features of band 6."
        ),
        BandDescriptor(
            band: 4,
            fluencyAndCoherence: "Unable to keep going without noticeable pauses.\n\nSpeech may be slow with frequent repetition.\n\nOften self-corrects.\n\nCan link simple sentences but often with repetitious use of connectives.\n\nSome breakdowns in coherence.",
            lexicalResource: "Resource sufficient for familiar topics but only basic meaning can be conveyed on unfamiliar topics.\n\nFrequent inappropriacies and errors in word choice.\n\nRarely attempts paraphrase.",
            grammaticalRangeAndAccuracy: "Can produce basic sentence forms and some short utterances are error-free.\n\nSubordinate clauses are rare and, overall, turns are short, structures are repetitive and errors are frequent.",
            pronunciation: "Uses some acceptable phonological features, but the range is limited.\n\nProduces some acceptable chunking, but there are frequent lapses in overall rhythm.\n\nAttempts to use intonation and stress, but control is limited.\n\nIndividual words or phonemes are frequently mispronounced, causing lack of clarity.\n\nUnderstanding requires some effort and there may be patches of speech that cannot be understood."
        ),
        BandDescriptor(
            band: 3,
            fluencyAndCoherence: "Frequent, sometimes long, pauses occur while candidate searches for words.\n\nLimited ability to link simple sentences and go beyond simple responses to questions.\n\nFrequently unable to convey basic message.",
            lexicalResource: "Resource limited to simple vocabulary used primarily to convey personal information.\n\nVocabulary inadequate for unfamiliar topics.",
            grammaticalRangeAndAccuracy: "Basic sentence forms are attempted but grammatical errors are numerous except in apparently memorised utterances.",
            pronunciation: "Displays some features of band 2, and some, but not all, of the positive features of band 4."
        ),
        BandDescriptor(
            band: 2,
            fluencyAndCoherence: "Lengthy pauses before nearly every word.\n\nIsolated words may be recognisable but speech is of virtually no communicative significance.",
            lexicalResource: "Very limited resource. Utterances consist of isolated words or memorised utterances.\n\nLittle communication possible without the support of mime or gesture.",
            grammaticalRangeAndAccuracy: "No evidence of basic sentence forms.",
            pronunciation: "Uses few acceptable phonological features (possibly because sample is insufficient).\n\nOverall problems with delivery impair attempts at connected speech.\n\nIndividual words and phonemes are mainly mispronounced and little meaning is conveyed.\n\nOften unintelligible."
        ),
        BandDescriptor(
            band: 1,
            fluencyAndCoherence: "Essentially none.\n\nSpeech is totally incoherent.",
            lexicalResource: "No resource bar a few isolated words.\n\nNo communication possible.",
            grammaticalRangeAndAccuracy: "No rateable language unless memorised.",
            pronunciation: "Can produce occasional individual words and phonemes that are recognisable, but no overall meaning is conveyed.\n\nUnintelligible."
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("IELTS Speaking Band Descriptors")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Official scoring criteria for Academic and General Training tests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
//                .background(Color(UIColor.secondarySystemBackground))
                
                Divider()
                    .padding(.horizontal, 20)
                
                
                // Band Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(bandDescriptors.enumerated()), id: \.offset) { index, descriptor in
                            BandButton(
                                band: descriptor.band,
                                isSelected: selectedBand == descriptor.band
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedBand = descriptor.band
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
                
                // Criteria Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(criteria, id: \.self) { criterion in
                            CriteriaButton(
                                title: criterion,
                                isSelected: selectedCriteria == criterion
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCriteria = criterion
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
//                .background(Color(UIColor.secondarySystemBackground))
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Band Header
                        HStack(alignment: .bottom) {
                            Text("Band \(selectedBand)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorForBand(selectedBand))
                            
                            Spacer()
                            
                            Text(selectedCriteria)
                                .font(.caption)
                                .foregroundColor(
                                    colorForBand(selectedBand)
                                )
                                .offset(y: -6)
                        }
                        
                        // Description
                        Text(getDescriptionForSelectedCriteria())
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                    }
                    .padding(20)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getDescriptionForSelectedCriteria() -> String {
        guard let descriptor = bandDescriptors.first(where: { $0.band == selectedBand }) else {
            return ""
        }
        
        switch selectedCriteria {
        case "Fluency and Coherence":
            return descriptor.fluencyAndCoherence
        case "Lexical Resource":
            return descriptor.lexicalResource
        case "Grammatical Range and Accuracy":
            return descriptor.grammaticalRangeAndAccuracy
        case "Pronunciation":
            return descriptor.pronunciation
        default:
            return ""
        }
    }
    
    private func colorForBand(_ band: Int) -> Color {
        switch band {
        case 9: return .green
        case 8: return Color(red: 0.6, green: 0.8, blue: 0.2)
        case 7: return .blue
        case 6: return Color(red: 0.2, green: 0.6, blue: 0.8)
        case 5: return .orange
        case 4: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case 3: return .red
        case 2: return Color(red: 0.8, green: 0.2, blue: 0.2)
        case 1: return Color(red: 0.6, green: 0.1, blue: 0.1)
        default: return .gray
        }
    }
}

struct BandButton: View {
    let band: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(band)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : colorForBand(band))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isSelected ? colorForBand(band) : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(colorForBand(band), lineWidth: 2)
                        )
                )
                .padding(4)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func colorForBand(_ band: Int) -> Color {
        switch band {
        case 9: return .green
        case 8: return Color(red: 0.6, green: 0.8, blue: 0.2)
        case 7: return .blue
        case 6: return Color(red: 0.2, green: 0.6, blue: 0.8)
        case 5: return .orange
        case 4: return Color(red: 0.9, green: 0.6, blue: 0.2)
        case 3: return .red
        case 2: return Color(red: 0.8, green: 0.2, blue: 0.2)
        case 1: return Color(red: 0.6, green: 0.1, blue: 0.1)
        default: return .gray
        }
    }
}

struct CriteriaButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(UIColor.tertiarySystemFill))
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Band Descriptors Navigation Button for HomeScreen
struct BandDescriptorsNavigationCard: View {
    @State private var showBandDescriptors = false
    
    var body: some View {
        Button(action: {
            showBandDescriptors = true
        }) {
            HStack(spacing: 16) {
                // Icon Section
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Band Descriptors")
                        .font(.custom("Fredoka-Medium", size: 18))
                        .foregroundColor(.primary)
                    
                    Text("Learn about IELTS scoring criteria")
                        .font(.custom("Fredoka-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Arrow Icon
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(showBandDescriptors ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showBandDescriptors)
        .sheet(isPresented: $showBandDescriptors) {
            IELTSSpeakingBandDescriptorsView()
        }
    }
}

// MARK: - Alternative Compact Button Version
struct BandDescriptorsCompactButton: View {
    @State private var showBandDescriptors = false
    
    var body: some View {
        Button(action: {
            showBandDescriptors = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                
                Text("Band Descriptors")
                    .font(.custom("Fredoka-Medium", size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showBandDescriptors) {
            IELTSSpeakingBandDescriptorsView()
        }
    }
}

// MARK: - Information Section with Band Descriptors
struct InformationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Information")
                    .font(.custom("Fredoka-Medium", size: 20))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                BandDescriptorsNavigationCard()
                
                // You can add more information cards here
                // ExamTipsCard()
                // StudyGuideCard()
            }
        }
    }
}

// Preview
struct IELTSSpeakingBandDescriptorsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IELTSSpeakingBandDescriptorsView()
            
            VStack(spacing: 20) {
                BandDescriptorsNavigationCard()
                BandDescriptorsCompactButton()
                InformationSection()
            }
            .padding()
            .previewDisplayName("Navigation Components")
        }
    }
}
