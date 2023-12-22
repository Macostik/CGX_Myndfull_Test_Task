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
    enum TimerCase {
        case timerA, timerB, timerC
        
        var name: String {
            switch self {
            case .timerA: return "Timer A"
            case .timerB: return "Timer B"
            case .timerC: return "Timer C"
            }
        }
    }
    struct State: Equatable {
        // Create buttons
        struct TimerButton: Equatable, Identifiable {
            var id: UUID
            var timer: TimerCase
            var percentage: Int
            var maxValue: Int
        }
        //Selection row
        var selectedTimer: Identified<TimerButton.ID, Timer.State?>?
        //Setup timer model
        var timerButtonList: IdentifiedArrayOf<TimerButton> = [
            TimerButton(id: UUID(),
                        timer: TimerCase.timerA,
                        percentage: 0,
                        maxValue: 60),
            TimerButton(id: UUID(),
                        timer: TimerCase.timerB,
                        percentage: 0,
                        maxValue: 90),
            TimerButton(id: UUID(),
                        timer: TimerCase.timerC,
                        percentage: 0,
                        maxValue: 120)
        ]
        // Calculate darkness level
        var darknessView: Double {
            guard let percentage = timerButtonList.first?.percentage else { return 0 }
            return percentage > 20 ? 0 : Double(percentage/100)
        }
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
                    await send(.setNavigationSelectionDelayCompleted)
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                // Perform navigation for selected row
            case .setNavigation(selection: .none):
                if let selectedTimer = state.selectedTimer,
                   let percentage = selectedTimer.value?.percentage {
                    state.timerButtonList[id: selectedTimer.id]?.percentage = percentage
                }
                print(state.darknessView)
                state.selectedTimer = nil
                return .cancel(id: CancelID.timer)
                
            case .setNavigationSelectionDelayCompleted:
                if let selectedTimer = state.selectedTimer,
                   let maxValue = state.timerButtonList[id: selectedTimer.id]?.maxValue {
                    state.selectedTimer?.value = Timer.State(isTimerActive: false,
                                                             secondsElapsed: 0,
                                                             maxValue: maxValue)
                   
                }
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




