//
//  ContentView.swift
//  Codex Test App
//
//  Created by Vongwadthy Khieu on 04.02.26.
//

import SwiftUI
import Combine

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
    @State private var tabSelection: AppSection = .home

    var body: some View {
        TabView(selection: $tabSelection) {
            sectionView(title: "Home", message: "Your dashboard lives here.", section: .home)
                .tabItem {
                    Label(AppSection.home.rawValue, systemImage: AppSection.home.systemImage)
                }
                .tag(AppSection.home)

            gameView
                .tabItem {
                    Label(AppSection.game.rawValue, systemImage: AppSection.game.systemImage)
                }
                .tag(AppSection.game)

            settingsView
                .tabItem {
                    Label(AppSection.settings.rawValue, systemImage: AppSection.settings.systemImage)
                }
                .tag(AppSection.settings)
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
                        QuickGameView(tabSelection: $tabSelection)
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

private struct KeypadButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct QuickGameView: View {
    enum GamePhase {
        case countdown
        case playing
        case finished
    }

    struct Question: Identifiable {
        let id = UUID()
        let text: String
        let answer: Int
    }

    @Binding var tabSelection: ContentView.AppSection

    @State private var phase: GamePhase = .countdown
    @State private var countdownRemaining = 5
    @State private var timeRemaining = 45
    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var input = ""
    @State private var showError = false
    @State private var elapsedTime = 0

    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private static let keypadDigits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private static let keypadColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 20) {
            header

            switch phase {
            case .countdown:
                countdownView
            case .playing:
                gameView
            case .finished:
                resultsView
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Quick Game")
        .onAppear(perform: startNewGame)
        .onReceive(countdownTimer) { _ in
            handleTick()
        }
    }

    private var header: some View {
        HStack {
            Text("Question \(min(currentIndex + 1, questions.count))/\(questions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            if phase == .playing {
                Text("\(timeRemaining)s")
                    .font(.headline)
                    .monospacedDigit()
            }
        }
    }

    private var countdownView: some View {
        VStack(spacing: 12) {
            Text("Get Ready")
                .font(.title)
                .fontWeight(.semibold)

            Text("Starting in \(countdownRemaining)")
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var gameView: some View {
        VStack(spacing: 16) {
            Text(currentQuestion.text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(input.isEmpty ? "Enter answer" : input)
                    .font(.title2)
                    .monospacedDigit()
                    .foregroundStyle(input.isEmpty ? .secondary : .primary)

                Spacer()

                Button("Clear") {
                    input = ""
                    showError = false
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

            if showError {
                Text("Incorrect. Try again.")
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .transition(.opacity)
            }

            keypad
        }
    }

    private var keypad: some View {
        LazyVGrid(columns: Self.keypadColumns, spacing: 12) {
            ForEach(Self.keypadDigits, id: \.self) { digit in
                KeypadButton(title: digit) {
                    appendDigit(digit)
                }
            }
        }
    }

    private var resultsView: some View {
        VStack(spacing: 16) {
            Text("Results")
                .font(.title)
                .fontWeight(.semibold)

            Text("Time: \(elapsedTime) seconds")
                .font(.headline)

            Button("Play Again") {
                startNewGame()
            }
            .buttonStyle(.borderedProminent)

            Button("Return to Home") {
                tabSelection = .home
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var currentQuestion: Question {
        if questions.indices.contains(currentIndex) {
            return questions[currentIndex]
        }
        return Question(text: "", answer: 0)
    }

    private func startNewGame() {
        questions = generateQuestions(count: 15)
        currentIndex = 0
        input = ""
        showError = false
        countdownRemaining = 5
        timeRemaining = 45
        elapsedTime = 0
        phase = .countdown
    }

    private func handleTick() {
        switch phase {
        case .countdown:
            if countdownRemaining > 1 {
                countdownRemaining -= 1
            } else {
                phase = .playing
            }
        case .playing:
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
            if timeRemaining == 0 {
                finishGame()
            }
        case .finished:
            break
        }
    }

    private func appendDigit(_ digit: String) {
        guard phase == .playing else { return }
        showError = false
        input.append(digit)

        let answerText = String(currentQuestion.answer)
        if input.count >= answerText.count {
            if input == answerText {
                moveToNextQuestion()
            } else {
                showError = true
                input = ""
            }
        }
    }

    private func moveToNextQuestion() {
        input = ""
        showError = false

        if currentIndex + 1 >= questions.count {
            finishGame()
        } else {
            currentIndex += 1
        }
    }

    private func finishGame() {
        if phase != .finished {
            if timeRemaining == 0 {
                elapsedTime = 45
            } else {
                elapsedTime = 45 - timeRemaining
            }
            phase = .finished
        }
    }

    private func generateQuestions(count: Int) -> [Question] {
        var generated: [Question] = []
        let operations: [(String, (Int, Int) -> Int)] = [
            ("+", { $0 + $1 }),
            ("-", { $0 - $1 }),
            ("×", { $0 * $1 }),
            ("÷", { $0 / $1 })
        ]

        while generated.count < count {
            let operation = operations.randomElement() ?? ("+", { $0 + $1 })
            let symbol = operation.0

            let question: Question
            switch symbol {
            case "×":
                let left = Int.random(in: 1...9)
                let right = Int.random(in: 1...9)
                question = Question(text: "\(left) × \(right) = ?", answer: left * right)
            case "+":
                let left = Int.random(in: 2...99)
                let right = Int.random(in: 2...99)
                question = Question(text: "\(left) + \(right) = ?", answer: left + right)
            case "-":
                let left = Int.random(in: 2...99)
                let right = Int.random(in: 2...left)
                question = Question(text: "\(left) - \(right) = ?", answer: left - right)
            case "÷":
                let right = Int.random(in: 2...12)
                let answer = Int.random(in: 2...12)
                let left = right * answer
                question = Question(text: "\(left) ÷ \(right) = ?", answer: answer)
            default:
                let left = Int.random(in: 1...9)
                let right = Int.random(in: 1...9)
                question = Question(text: "\(left) + \(right) = ?", answer: left + right)
            }

            generated.append(question)
        }

        return generated
    }
}

#Preview {
    ContentView()
}
