//
//  Timer.swift
//  CGX_Myndfull_Test_Task
//
//  Created by Macostik on 22.12.2023.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct Timer {
  struct State: Equatable {
    var isTimerActive = false
    var secondsElapsed = 0
  }

  enum Action {
    case onDisappear
    case timerTicked
    case toggleTimerButtonTapped
  }

  @Dependency(\.continuousClock) var clock
  private enum CancelID { case timer }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onDisappear:
        return .cancel(id: CancelID.timer)

      case .timerTicked:
        state.secondsElapsed += 1
        return .none

      case .toggleTimerButtonTapped:
        state.isTimerActive.toggle()
        return .run { [isTimerActive = state.isTimerActive] send in
          guard isTimerActive else { return }
          for await _ in self.clock.timer(interval: .seconds(1)) {
            await send(.timerTicked, animation: .default)
          }
        }
        .cancellable(id: CancelID.timer, cancelInFlight: true)
      }
    }
  }
}

struct TimerView: View {
    var store: StoreOf<Timer>
    var body: some View {
        Text("New Timer")
    }
}
