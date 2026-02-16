//
//  LogManager.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import Foundation
import Combine

@MainActor
class LogManager: ObservableObject {
    static let shared = LogManager()
    
    @Published var logs: [Log] = []
    
    private init() {}
    
    func clearLog() {
        self.logs = []
    }
    
    func log(log: Log) {
        logs.append(log)
    }
}
