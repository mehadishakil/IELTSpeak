import SwiftUI

struct FeedbackView: View {
    @State private var rating: Int = 5
    @State private var comment: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rating")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("How would you rate your experience?")
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            
            Text("Comment (optional)")
                .font(.headline)
            
            TextEditor(text: $comment)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
            Spacer()
            
            Button(action: {
                // Handle sending feedback
            }) {
                Text("Send Feedback")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    FeedbackView()
}
