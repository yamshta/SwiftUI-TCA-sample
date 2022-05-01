//
//  SwiftUI_TCA_sampleApp.swift
//  SwiftUI-TCA-sample
//
//  Created by yamshta on 2022/05/01.
//

import SwiftUI
import ComposableArchitecture

@main
struct SwiftUI_TCA_sampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(
                        todos:  [
                            Todo(
                                description: "Milk",
                                id: UUID(),
                                isComplete: false
                            ),
                            Todo(
                                description: "Eggs",
                                id: UUID(),
                                isComplete: false
                            ),
                            Todo(
                                description: "Hand Soap",
                                id: UUID(),
                                isComplete: true
                            ),
                        ]
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                )
            )
        }
    }
}
