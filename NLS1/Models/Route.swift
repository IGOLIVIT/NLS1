//
//  Route.swift
//  NLS1
//

import Foundation

enum Route: Hashable {
    case home
    case levels
    case run(levelId: Int)
    case training
    case trainingModule(moduleId: String)
    case archive
    case settings
    case onboarding
}
