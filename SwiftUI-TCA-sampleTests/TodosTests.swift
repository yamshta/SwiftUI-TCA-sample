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

    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.addTodoButtonTapped) {
            $0.todos.insert(
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    isComplete: false
                ),
                at: 0
            )
        }
    }

    func testCompletingTodo() {
        let state = AppState(
            todos: [
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    isComplete: false
                ),
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    isComplete: false
                ),
            ]
        )

        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid:  UUID.init)
        )

        store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
            $0.todos[id: state.todos[0].id]?.isComplete = true
        }

        scheduler.advance(by: 1)

        store.receive(.sortCompletedTodos) {
            $0.todos = [
                $0.todos[1],
                $0.todos[0],
            ]
        }
    }

    func testCompleteTodoDebounces() {
        let state = AppState(
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
        )

        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
            $0.todos[id: state.todos[0].id]?.isComplete = true
        }

        scheduler.advance(by: 0.5)

        store.send(.todo(id: state.todos[0].id, action: .checkBoxToggled)) {
            $0.todos[id: state.todos[0].id]?.isComplete = false
        }

        scheduler.advance(by: 1)

        store.receive(.sortCompletedTodos)
    }
}
