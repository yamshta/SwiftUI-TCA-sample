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
            TodosView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
