//
//  ContentView.swift
//  Codex Test App
//
//  Created by Vongwadthy Khieu on 04.02.26.
//

import SwiftUI

struct ContentView: View {
    enum AppSection: String, CaseIterable, Identifiable {
        case home = "Home"
        case game = "Game"
        case settings = "Settings"

        var id: String { rawValue }
        var systemImage: String {
            switch self {
            case .home: return "house"
            case .game: return "gamecontroller"
            case .settings: return "gearshape"
            }
        }
    }

    @AppStorage("appAppearanceIsDark") private var appAppearanceIsDark = false

    var body: some View {
        TabView {
            sectionView(title: "Home", message: "Your dashboard lives here.", section: .home)
                .tabItem {
                    Label(AppSection.home.rawValue, systemImage: AppSection.home.systemImage)
                }

            gameView
                .tabItem {
                    Label(AppSection.game.rawValue, systemImage: AppSection.game.systemImage)
                }

            settingsView
                .tabItem {
                    Label(AppSection.settings.rawValue, systemImage: AppSection.settings.systemImage)
                }
        }
        .preferredColorScheme(appAppearanceIsDark ? .dark : .light)
    }

    private func sectionView(title: String, message: String, section: AppSection) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Welcome! Use the tabs below to switch sections.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    Image(systemName: section.systemImage)
                        .font(.title2)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Codex Test App")
        }
    }

    private var gameView: some View {
        NavigationStack {
            List {
                Section("Start Playing") {
                    NavigationLink("Quick Game") {
                        GameDetailView(title: "Quick Game", message: "Game logic will be added here later.")
                    }

                    NavigationLink("Daily Puzzle") {
                        GameDetailView(title: "Daily Puzzle", message: "Daily puzzle logic will be added here later.")
                    }

                    NavigationLink("Custom Game") {
                        GameDetailView(title: "Custom Game", message: "Choose your configuration before starting the game.")
                    }
                }
            }
            .navigationTitle("Game")
        }
    }

    private var settingsView: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Appearance")
                        .font(.headline)

                    Toggle("Dark Mode", isOn: $appAppearanceIsDark)
                        .toggleStyle(.switch)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

struct GameDetailView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}
