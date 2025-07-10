import SwiftUI

struct ContactUsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Description
            Text("You can get in touch with us through below platforms. Our Team will reach out to you as soon as it would be possible")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Customer Support Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Customer Support")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "phone")
                    Text("Mobile")
                    Spacer()
                    Text("+966 50 389 2733")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "envelope")
                    Text("Email")
                    Spacer()
                    Text("unchair305@gmail.com")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Social Media Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Social Media")
                    .font(.headline)
                
                HStack {
                    Image("instagram")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Instagram")
                    Spacer()
                    Text("@unchair305")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                
                HStack {
                    Image("x")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Twitter")
                    Spacer()
                    Text("@UnChair305")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Contact Us")
    }
}

#Preview {
    ContactUsView()
}
