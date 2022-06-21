import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates how the `Reducer` struct can be extended to enhance reducers with extra \
  functionality.

  In it we introduce an interface for constructing reducers that need to be called recursively in \
  order to handle nested state and actions. It is handed itself as its first argument.

  Tap "Add row" to add a row to the current screen's list. Tap the left-hand side of a row to edit \
  its description, or tap the right-hand side of a row to navigate to its own associated list of \
  rows.
  """

struct Nested: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var children: IdentifiedArrayOf<State> = []
    let id: UUID
    var description: String = ""
  }

  enum Action: Equatable {
    case append
    indirect case node(id: State.ID, action: Action)
    case remove(IndexSet)
    case rename(String)
  }

  @Dependency(\.uuid) var uuid

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .append:
        state.children.append(State(id: self.uuid()))
        return .none

      case .node:
        return .none

      case let .remove(indexSet):
        state.children.remove(atOffsets: indexSet)
        return .none

      case let .rename(name):
        state.description = name
        return .none
      }
    }
    .forEach(state: \.children, action: /Action.node) {
      self
    }
  }
}

struct NestedView: View {
  let store: StoreOf<Nested>

  var body: some View {
    WithViewStore(self.store.scope(state: \.description)) { viewStore in
      Form {
        Section(header: Text(template: readMe, .caption)) {

          ForEachStore(
            self.store.scope(state: \.children, action: Nested.Action.node(id:action:))
          ) { childStore in
            WithViewStore(childStore) { childViewStore in
              HStack {
                TextField(
                  "Untitled",
                  text: childViewStore.binding(get: \.description, send: Nested.Action.rename)
                )

                Spacer()

                NavigationLink(
                  destination: NestedView(store: childStore)
                ) {
                  Text("")
                }
              }
            }
          }
          .onDelete { viewStore.send(.remove($0)) }
        }
      }
      .navigationBarTitle(viewStore.state.isEmpty ? "Untitled" : viewStore.state)
      .navigationBarItems(
        trailing: Button("Add row") { viewStore.send(.append) }
      )
    }
  }
}

extension Nested.State {
  static let mock = Self(
    children: [
      Self(
        children: [
          Self(
            children: [],
            id: UUID(),
            description: ""
          )
        ],
        id: UUID(),
        description: "Bar"
      ),
      Self(
        children: [
          Self(
            children: [],
            id: UUID(),
            description: "Fizz"
          ),
          Self(
            children: [],
            id: UUID(),
            description: "Buzz"
          ),
        ],
        id: UUID(),
        description: "Baz"
      ),
      Self(
        children: [],
        id: UUID(),
        description: ""
      ),
    ],
    id: UUID(),
    description: "Foo"
  )
}

#if DEBUG
  struct NestedView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        NestedView(
          store: Store(
            initialState: .mock,
            reducer: Nested()
          )
        )
      }
    }
  }
#endif
