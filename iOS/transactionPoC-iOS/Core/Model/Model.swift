//
//  Model.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 4.02.2026.
//
import SwiftUI

struct transactionRequest: Identifiable, Codable {
    let amount: Double
    let iban: String
    let desc: String
    var id = UUID()
}

struct Log: Identifiable {
    var id = UUID()
    let who: String
    let logText: String
    let color: Color
}


