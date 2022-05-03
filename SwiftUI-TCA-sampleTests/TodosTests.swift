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

    func testEditTodo() {
        let state = AppState(
            todos: [
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    isComplete: false
                )
            ]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(
            .todo(id: state.todos[0].id, action: .textFieldChanged("Learn Composable Architecture"))
        ) {
            $0.todos[id: state.todos[0].id]?.description = "Learn Composable Architecture"
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

    func testClearCompleted() {
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
                    isComplete: true
                ),
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

        store.send(.clearCompletedButtonTapped) {
            $0.todos = [
                $0.todos[0]
            ]
        }
    }

    func testDelete() {
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
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    isComplete: false
                ),
            ]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.delete([1])) {
            $0.todos = [
                $0.todos[0],
                $0.todos[2],
            ]
        }
    }

    func testEditModeMoving() {
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
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    isComplete: false
                ),
            ]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.editModeChanged(.active)) {
            $0.editMode = .active
        }
        store.send(.move([0], 2)) {
            $0.todos = [
                $0.todos[1],
                $0.todos[0],
                $0.todos[2],
            ]
        }
        self.scheduler.advance(by: .milliseconds(100))
        store.receive(.sortCompletedTodos)
    }

    func testEditModeMovingWithFilter() {
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
                    isComplete: true
                ),
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                    isComplete: false
                ),
                Todo(
                    description: "",
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                    isComplete: true
                ),
            ]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.editModeChanged(.active)) {
            $0.editMode = .active
        }
        store.send(.filterPicked(.completed)) {
            $0.filter = .completed
        }
        store.send(.move([0], 1)) {
            $0.todos = [
                $0.todos[0],
                $0.todos[2],
                $0.todos[1],
                $0.todos[3],
            ]
        }
        self.scheduler.advance(by: .milliseconds(100))
        store.receive(.sortCompletedTodos)
    }

    func testFilteredEdit() {
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
                    isComplete: true
                ),
            ]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: self.scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )

        store.send(.filterPicked(.completed)) {
            $0.filter = .completed
        }
        store.send(.todo(id: state.todos[1].id, action: .textFieldChanged("Did this already"))) {
            $0.todos[id: state.todos[1].id]?.description = "Did this already"
        }
    }
}
