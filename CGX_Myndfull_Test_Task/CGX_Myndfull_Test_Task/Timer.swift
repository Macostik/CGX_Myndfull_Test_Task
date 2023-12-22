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
        var percentage = 0
        var maxValue = 0
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
            
        //Release time when view disappear
            switch action {
            case .onDisappear:
                return .cancel(id: CancelID.timer)
        //Calculate percentage for each case
            case .timerTicked:
                state.secondsElapsed += 1
                state.percentage = min(100, Int(Double(state.secondsElapsed)/Double(state.maxValue) * 100.0))
                return .none
         //Start/Stop timer with interval of 1 second
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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                Button("Start / Pause") {
                    viewStore.send(.toggleTimerButtonTapped)
                }
                .padding()
                .background(.gray)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                
                Text("\(viewStore.percentage) %")
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimerView(
                store: Store(
                    initialState: Timer.State(isTimerActive: false, secondsElapsed: 0)
                ) {
                    Timer()
                }
            )
        }
        .navigationViewStyle(.stack)
    }
}

