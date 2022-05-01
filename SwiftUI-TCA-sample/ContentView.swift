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

struct AppState: Equatable {
    var todos: [Todo]
}

enum AppAction {
    case todoCheckboxTapped(index: Int)
    case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case let .todoCheckboxTapped(index):
        state.todos[index].isComplete.toggle()
        return .none
    case let .todoTextFieldChanged(index, text):
        state.todos[index].description = text
        return .none
    }
}
.debug()

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEach(Array(viewStore.state.todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                          Button {
                              viewStore.send(.todoCheckboxTapped(index: index))
                          } label: {
                            Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                          }
                          .buttonStyle(PlainButtonStyle())

                          TextField(
                            "Untitled todo",
                            text: viewStore.binding(
                                get: { $0.todos[index].description },
                                send: { .todoTextFieldChanged(index: index, text: $0) }
                            )
                          )
                        }
                        .foregroundColor(todo.isComplete ? .gray : nil)
                    }
                    Text("Hello, world!")
                }
                .navigationTitle("Todos")
            }
        }
        .navigationViewStyle(.stack) // 制約の警告を非表示にするため
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
                environment: AppEnvironment()
            )
        )
    }
}
