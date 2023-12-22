//
//  TimerListView.swift
//  CGX_Myndfull_Test_Task
//
//  Created by Macostik on 22.12.2023.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Feature view

struct TimerListView: View {
    @State var store = Store(initialState: TimerList.State()) {
        TimerList()
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
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
                TimerList.State.TimerButton(id: UUID(),
                                            name: "Timer A",
                                            percentage: 0,
                                            maxValue: 0)
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

