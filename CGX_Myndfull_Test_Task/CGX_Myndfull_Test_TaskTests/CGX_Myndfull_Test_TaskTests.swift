//
//  CGX_Myndfull_Test_TaskTests.swift
//  CGX_Myndfull_Test_TaskTests
//
//  Created by Macostik on 22.12.2023.
//

import ComposableArchitecture
import XCTest

@testable import CGX_Myndfull_Test_Task

@MainActor
final class TimersTests: XCTestCase {
  func testStart() async {
    let clock = TestClock()

    let store = TestStore(initialState: Timer.State()) {
      Timer()
    } withDependencies: {
      $0.continuousClock = clock
    }

    await store.send(.toggleTimerButtonTapped) {
      $0.isTimerActive = true
    }
    await clock.advance(by: .seconds(1))
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 1
    }
    await clock.advance(by: .seconds(5))
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 2
    }
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 3
    }
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 4
    }
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 5
    }
    await store.receive(\.timerTicked) {
      $0.secondsElapsed = 6
    }
    await store.send(.toggleTimerButtonTapped) {
      $0.isTimerActive = false
    }
  }
}
