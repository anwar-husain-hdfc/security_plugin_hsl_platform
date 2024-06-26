//
//  SimulatorChecker.swift
//  Runner
//
//  Created by Keshav Raj on 10/06/24.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation

internal struct SimulatorChecker {
    
    func amIRunInSimulator() -> Bool {
        return checkCompile() || checkRuntime()
    }
    
    private  func checkRuntime() -> Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
    
    private  func checkCompile() -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
}

