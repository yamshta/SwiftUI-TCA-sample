//
//  Todo.swift
//  SwiftUI-TCA-sample
//
//  Created by yamshta on 2022/05/02.
//

import Foundation

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkBoxToggled
    case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkBoxToggled:
        state.isComplete.toggle()
        return .none

    case let .textFieldChanged(text):
        state.description = text
        return .none
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkBoxToggled) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())

                TextField(
                    "Untitled Todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}
