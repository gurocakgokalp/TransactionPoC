//
//  Models.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor
struct UserSession {
    let clientAgreementPublicKey: String
    let clientSignPublicKey: String
    var sharedSessionKey: SymmetricKey?
}

struct transactionRequest: Identifiable, Codable {
    let amount: Double
    let iban: String
    let desc: String
    let replayNonce: String
    let timestamp: Int64
}

