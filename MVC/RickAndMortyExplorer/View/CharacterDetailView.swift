//
//  CharacterDetailView.swift
//  RickAndMortyExplorer
//
//  Created by Toly on 29.09.2025.
//

import SwiftUI
import RickMortySwiftApi

struct CharacterDetailView: View {
    let character: RMCharacterModel
    let episodes: [RMEpisodeModel]
    let isLoading: Bool
    let errorMessage: String?

    @State private var animateSequence = false
    @State private var animateLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                characterImage
                characterName
                characterDetails
                Divider().padding(.vertical, 10)
                episodesSection
            }
            .padding()
            .opacity(animateSequence ? 1 : 0)
            .offset(y: animateSequence ? 0 : 40)
            .animation(.easeOut(duration: 0.6), value: animateSequence)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateSequence = true
            animateLoading = isLoading
        }
        .onDisappear {
            animateSequence = false
            animateLoading = false
        }
    }

    // MARK: - Subviews
    private var characterImage: some View {
        AsyncImage(url: URL(string: character.image)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .scaleEffect(animateSequence ? 1 : 0.88)
                    .opacity(animateSequence ? 1 : 0)
                    .offset(y: animateSequence ? 0 : 28)
                    .animation(.interpolatingSpring(stiffness: 220, damping: 20).speed(1.0), value: animateSequence)
            case .failure:
                Image(systemName: "person.fill.questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 40,
                           height: UIScreen.main.bounds.width - 40)
                    .foregroundColor(.gray)
                    .scaleEffect(animateSequence ? 1 : 0.88)
                    .opacity(animateSequence ? 1 : 0)
                    .offset(y: animateSequence ? 0 : 28)
                    .animation(.interpolatingSpring(stiffness: 220, damping: 20).speed(1.0), value: animateSequence)
            @unknown default:
                EmptyView()
            }
        }
    }

    private var characterName: some View {
        Text(character.name)
            .font(.title)
            .fontWeight(.bold)
            .opacity(animateSequence ? 1 : 0)
            .offset(y: animateSequence ? 0 : 18)
            .animation(.easeOut(duration: 0.45).delay(0.08), value: animateSequence)
    }

    private var characterDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Status: \(character.status)").foregroundColor(colorForStatus(character.status))
            Text("Species: \(character.species)")
            Text("Gender: \(character.gender)")
            Text("Origin: \(character.origin.name)")
            Text("Location: \(character.location.name)")
        }
        .opacity(animateSequence ? 1 : 0)
        .offset(y: animateSequence ? 0 : 12)
        .animation(.easeOut(duration: 0.45).delay(0.16), value: animateSequence)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var episodesSection: some View {
        Group {
            if isLoading {
                loadingView
                    .opacity(animateSequence ? 1 : 0)
                    .offset(y: animateSequence ? 0 : 12)
                    .animation(.easeOut(duration: 0.45).delay(0.24), value: animateSequence)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .opacity(animateSequence ? 1 : 0)
                    .offset(y: animateSequence ? 0 : 12)
                    .animation(.easeOut(duration: 0.45).delay(0.24), value: animateSequence)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Episodes:").font(.headline)
                        .opacity(animateSequence ? 1 : 0)
                        .offset(y: animateSequence ? 0 : 8)
                        .animation(.easeOut(duration: 0.35).delay(0.26), value: animateSequence)

                    ForEach(Array(episodes.enumerated()), id: \.element.id) { index, episode in
                        HStack {
                            Text(episode.episode).bold()
                            Text(episode.name)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animateSequence ? 1 : 0)
                        .offset(y: animateSequence ? 0 : 12)
                        .animation(
                            .easeOut(duration: 0.36)
                                .delay(0.3 + Double(index) * 0.06),
                            value: animateSequence
                        )
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
                    .scaleEffect(animateLoading ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: animateLoading
                    )
            }
            Text("Loading episodes...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear { if isLoading { animateLoading = true } }
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "Alive": return .green
        case "Dead": return .red
        default: return .gray
        }
    }
}
