//
//  ContentView.swift
//  SwiftUI-TCA-sample
//
//  Created by yamshta on 2022/05/01.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var todos: IdentifiedArrayOf<Todo> = []
}

enum AppAction: Equatable {
    case addTodoButtonTapped
    case todo(id: Todo.ID, action: TodoAction)
    case sortCompletedTodos
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
        action: /AppAction.todo(id:action:),
        environment: { _ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addTodoButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none

        case .sortCompletedTodos:
            state.todos.sort { $1.isComplete && !$0.isComplete }
            return .none

        case .todo(id: _, action: .checkBoxToggled):
            struct CancelDelayId: Hashable {}
            return Effect(value: .sortCompletedTodos)
                .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue.animation())

        case .todo:
            return .none
        }
    }
)

struct TodosView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(
                            state: \.todos,
                            action: AppAction.todo(id:action:)
                        ),
                        content: TodoView.init(store:)
                    )
                    Text("Hello, world!")
                }
                .navigationTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addTodoButtonTapped)
                })
            }
        }
        .navigationViewStyle(.stack) // 制約の警告を非表示にするため
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TodosView(
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
                environment: AppEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                    uuid: UUID.init
                )
            )
        )
    }
}
