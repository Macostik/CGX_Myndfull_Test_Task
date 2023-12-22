//
//  TimerList.swift
//  CGX_Myndfull_Test_Task
//
//  Created by Macostik on 22.12.2023.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Main domain where all login happen
@Reducer
struct TimerList {
    // State of main reducer
    struct State: Equatable {
        // Create buttons
        struct TimerButton: Equatable, Identifiable {
            var id: UUID
            var name: String
            var percentage = 0
        }
        //Selection row
        var selectedTimer: Identified<TimerButton.ID, Timer.State?>?
        
        var timerButtonList: IdentifiedArrayOf<TimerButton> = [
            TimerButton(id: UUID(), name: "Timer A", percentage: 0),
            TimerButton(id: UUID(), name: "Timer B", percentage: 0),
            TimerButton(id: UUID(), name: "Timer C", percentage: 0)
        ]
    }
    // Action of main reducer
    enum Action {
        case timer(Timer.Action)
        case setNavigation(selection: UUID?)
        case setNavigationSelectionDelayCompleted
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case timer }

    var body: some Reducer<State, Action> {
      Reduce { state, action in
        switch action {
        case .timer:
          return .none
            // Perform pop to root view for selected row
        case let .setNavigation(selection: .some(id)):
          state.selectedTimer = Identified(nil, id: id)
          return .run { send in
            try await self.clock.sleep(for: .seconds(1))
            await send(.setNavigationSelectionDelayCompleted)
          }
          .cancellable(id: CancelID.timer, cancelInFlight: true)
            // Perform navigation for selected row
        case .setNavigation(selection: .none):
            if let selectedTimer = state.selectedTimer,
                let percentage = selectedTimer.value?.secondsElapsed {
                state.timerButtonList[id: selectedTimer.id]?.percentage = percentage
          }
          state.selectedTimer = nil
          return .cancel(id: CancelID.timer)

        case .setNavigationSelectionDelayCompleted:
          guard let id = state.selectedTimer?.id else { return .none }
          state.selectedTimer?.value = Timer.State(isTimerActive: false, secondsElapsed: 0)
          return .none
        }
      }
      .ifLet(\.selectedTimer, action: \.timer) {
        EmptyReducer()
          .ifLet(\.value, action: \.self) {
            Timer()
          }
      }
    }
}

// MARK: - Feature view

struct TimerListView: View {
    @State var store = Store(initialState: TimerList.State()) {
        TimerList()
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Section {
                ForEach(viewStore.timerButtonList) { row in
                    NavigationLink(
                        "\(row.name)    \(row.percentage)",
                        tag: row.id,
                        selection: viewStore.binding(
                            get: \.selectedTimer?.id,
                            send: { .setNavigation(selection: $0) }
                        )
                    ) {
                        IfLetStore(self.store.scope(state: \.selectedTimer?.value, action: \.timer)) {
                            TimerView(store: $0)
                        } else: {
                            ProgressView()
                        }
                        .navigationTitle("Timer List")
                    }
                }
            }
        }
    }
}
    
    // MARK: - SwiftUI previews

struct TimerListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
        TimerListView(
        store: Store(
          initialState: TimerList.State(
            timerButtonList: [
                TimerList.State.TimerButton(id: UUID(), name: "Timer A", percentage: 0)
            ]
          )
        ) {
            TimerList()
        }
      )
    }
    .navigationViewStyle(.stack)
  }
}


