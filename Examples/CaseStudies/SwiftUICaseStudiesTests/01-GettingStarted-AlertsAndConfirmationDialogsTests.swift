import Combine
import ComposableArchitecture
import SwiftUI
import XCTest

@testable import SwiftUICaseStudies

@MainActor
class AlertsAndConfirmationDialogsTests: XCTestCase {
  func testAlert() async {
    let store = TestStore(
      initialState: AlertAndConfirmationDialogState(),
      reducer: alertAndConfirmationDialogReducer,
      environment: AlertAndConfirmationDialogEnvironment()
    )

    await store.send(.alertButtonTapped) {
      $0.alert = AlertState(
        title: TextState("Alert!"),
        message: TextState("This is an alert"),
        primaryButton: .cancel(TextState("Cancel")),
        secondaryButton: .default(TextState("Increment"), action: .send(.incrementButtonTapped))
      )
    }
    await store.send(.incrementButtonTapped) {
      $0.alert = AlertState(title: TextState("Incremented!"))
      $0.count = 1
    }
    await store.send(.alertDismissed) {
      $0.alert = nil
    }
  }

  func testConfirmationDialog() async {
    let store = TestStore(
      initialState: AlertAndConfirmationDialogState(),
      reducer: alertAndConfirmationDialogReducer,
      environment: AlertAndConfirmationDialogEnvironment()
    )

    await store.send(.confirmationDialogButtonTapped) {
      $0.confirmationDialog = ConfirmationDialogState(
        title: TextState("Confirmation dialog"),
        message: TextState("This is a confirmation dialog."),
        buttons: [
          .cancel(TextState("Cancel")),
          .default(TextState("Increment"), action: .send(.incrementButtonTapped)),
          .default(TextState("Decrement"), action: .send(.decrementButtonTapped)),
        ]
      )
    }
    await store.send(.incrementButtonTapped) {
      $0.alert = AlertState(title: TextState("Incremented!"))
      $0.count = 1
    }
    await store.send(.confirmationDialogDismissed) {
      $0.confirmationDialog = nil
    }
  }
}
