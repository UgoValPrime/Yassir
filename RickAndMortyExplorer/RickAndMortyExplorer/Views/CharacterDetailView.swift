import SwiftUI

struct CharacterDetailView: View {
    let character: CharacterDetail
    let cachedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack() {
            // Character Image
            ZStack(alignment: .topLeading) {
                
                if let image = cachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(height: UIScreen.main.bounds.height * 0.55)
                        .scaledToFill()
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                } else {
                    AsyncImage(url: URL(string: character.imageUrl)) { image in
                        image
                            .resizable()
                            .frame(height: UIScreen.main.bounds.height * 0.55)
                            .scaledToFill()
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                    } placeholder: {
                        ProgressView()
                            .frame(height: UIScreen.main.bounds.height * 0.55) // Match placeholder height
                    }
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 16)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Status Capsule
                    Text(character.status)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(for: character.status))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Text("\(character.species) • \(character.gender)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Location: ")
                        .fontWeight(.bold)
                    Text(character.location)
                }
                .font(.body)
                .foregroundColor(.black)
            }
            .padding(.horizontal)
            .background(Color.white)
            .offset(y: -(UIScreen.main.bounds.height * 0.05) )
            Spacer()
        }
        .navigationBarHidden(true)
    }
    
    // Helper function to determine capsule color
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .gray
        }
    }
}
