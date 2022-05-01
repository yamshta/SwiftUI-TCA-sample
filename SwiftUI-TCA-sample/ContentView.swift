//
//  ContentView.swift
//  SwiftUI-TCA-sample
//
//  Created by yamshta on 2022/05/01.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case let .textFieldChanged(text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayCompleted
}

struct AppEnvironment {
    var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
        case .todo(index: _, action: .checkboxTapped):
            struct CancelDelayId: Hashable {}
            return Effect(value: .todoDelayCompleted)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
                .cancellable(id: CancelDelayId(), cancelInFlight: true)
        case .todo:
            return .none
        case .todoDelayCompleted:
            state.todos = state.todos
                .enumerated()
                .sorted { lhs, rhs in
                    (!lhs.element.isComplete && rhs.element.isComplete || lhs.offset < rhs.offset)
                }
                .map(\.element)
            return .none
        }
    }
)

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(
                            state: \.todos,
                            action: AppAction.todo(index:action:)
                        ),
                        content: TodoView.init(store:)
                    )
                    Text("Hello, world!")
                }
                .navigationTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped)
                })
            }
        }
        .navigationViewStyle(.stack) // 制約の警告を非表示にするため
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())

                TextField(
                    "Untitled Todo",
                    text: viewStore.binding(
                        get: { $0.description },
                        send: { .textFieldChanged($0) }
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
                environment: AppEnvironment(uuid: UUID.init)
            )
        )
    }
}
