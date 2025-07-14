import SwiftUI

struct FeedbackPost: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let upvotes: Int
    let comments: Int
    let status: String
    let statusColor: Color
}

struct FeedbackBoardView: View {
    let posts: [FeedbackPost] = [
        FeedbackPost(title: "Same task over multiple timeslots",
                     description: "Should be able to work on the same task multiple different time slots...",
                     upvotes: 245, comments: 42,
                     status: "", statusColor: .clear),

        FeedbackPost(title: "Multi-Label Tasks",
                     description: "The ability to add more than one label to a task would be a nice touch...",
                     upvotes: 212, comments: 17,
                     status: "Under Review", statusColor: .gray),

        FeedbackPost(title: "Add External Calendar Events As Tasks",
                     description: "Being able to add Gcal events as tasks so the time etc can be tracked...",
                     upvotes: 189, comments: 62,
                     status: "In Progress", statusColor: .pink),

        FeedbackPost(title: "Timeboxed tasks should reflect actual time",
                     description: "After being marked complete, the timeboxed task reflects the estimated time...",
                     upvotes: 121, comments: 16,
                     status: "Planned", statusColor: .blue),

        FeedbackPost(title: "Add, edit, or delete Google calendar events",
                     description: "Have the ability to create, edit, and delete Google calendar events...",
                     upvotes: 116, comments: 24,
                     status: "In Progress", statusColor: .pink)
    ]

    var body: some View {
        NavigationView {
            List(posts) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Text(post.title)
                        .font(.headline)
                      
                    Text(post.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)

                    HStack(alignment: .center) {
                        Image(systemName: "text.bubble")
                        Text("\(post.comments)")
                        
                        if !post.status.isEmpty {
                            Text(post.status)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(post.statusColor.opacity(0.2))
                                .foregroundColor(post.statusColor)
                                .cornerRadius(8)
                        }

                        Spacer()

                        Button {
                            //
                        } label: {
                            VStack(spacing: 4){
                                Image(systemName: "arrowtriangle.up.fill")
                                Text("\(post.upvotes)")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 6,
                                    style: .continuous,
                                )
                                .fill(.ultraThinMaterial)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        }

                    }
                    .padding(.vertical, 2)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Request Feature")
    }
}

#Preview {
    FeedbackBoardView()
}
