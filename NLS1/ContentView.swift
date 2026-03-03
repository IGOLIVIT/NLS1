//
//  ContentView.swift
//  NLS1
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progress = ProgressStore.shared
    @State private var path: [Route] = []

    var body: some View {
        Group {
            if !progress.onboardingCompleted {
                OnboardingView(completed: $progress.onboardingCompleted)
            } else if #available(iOS 16.0, *) {
                NavigationStack(path: $path) {
                    HomeView(path: $path)
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route, path: $path)
                        }
                }
            } else {
                NavigationView {
                    Group {
                        if path.isEmpty {
                            HomeView(path: $path)
                        } else {
                            destinationView(for: path.last!, path: $path)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("Back") { path.removeLast() }
                                            .foregroundColor(Theme.textPrimary)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .environmentObject(progress)
    }

    @ViewBuilder
    private func destinationView(for route: Route, path: Binding<[Route]>) -> some View {
        switch route {
        case .home:
            EmptyView()
        case .levels:
            LevelsView(path: path)
        case .run(let levelId):
            RunView(path: path, levelId: levelId)
                .id(levelId)
        case .training:
            TrainingView(path: path)
        case .trainingModule(let moduleId):
            TrainingModuleView(path: path, moduleId: moduleId)
        case .archive:
            ArchiveView(path: path)
        case .settings:
            SettingsView(path: path)
        case .onboarding:
            EmptyView()
        }
    }
}

#Preview {
    ContentView()
}
