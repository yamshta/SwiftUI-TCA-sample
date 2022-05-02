//
//  TodosTests.swift
//  SwiftUI-TCA-sampleTests
//
//  Created by yamshta on 2022/05/01.
//

import ComposableArchitecture
import XCTest
@testable import SwiftUI_TCA_sample

class TodosTests: XCTestCase {
    let scheduler = DispatchQueue.test

    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        description: "Milk",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid:  UUID.init)
        )

        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }

    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
            )
        )

        store.assert(
            .send(.addButtonTapped) {
                $0.todos = [
                    Todo(
                        description: "",
                        id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!,
                        isComplete: false
                    )
                ]
            }
        )
    }

    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        description: "Milk",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        isComplete: false
                    ),
                    Todo(
                        description: "Eggs",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("unimplemented") }
            )
        )

        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted) {
                $0.todos.swapAt(0, 1)
            }
        )
    }

    func testTodoSorting_Cancellation() {
        let todos = [
            Todo(
                description: "Milk",
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                isComplete: false
            ),
            Todo(
                description: "Eggs",
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                isComplete: false
            )
        ]

        let store = TestStore(
            initialState: AppState(todos: todos),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError("unimplemented") }
            )
        )

        store.assert(
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 0.5)
            },
            .send(.todo(index: 0, action: .checkboxTapped)) {
                $0.todos[0].isComplete = false
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayCompleted)
        )
    }
}
