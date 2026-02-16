//
//  DTOs.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import SwiftUI

//ios - codable, vapor - content
struct handshakeRequest: Codable {
    let deviceId: String
}

struct enrollRequest: Codable {
    let clientPublicKey: String
    let clientSignPublicKey: String
    let deviceId: String
}

struct handshakeResponse: Codable {
    let serverPublicKey: String
    let status: String
    let salt: String
    let message: String
}

struct encryptedRequest: Codable {
    let ciphertext: String
    let signature: String
    let nonce: String
    let tag: String
    let deviceID: String
}

struct decryptResponse: Codable {
    let status: String
    let message: String
}

struct enrollResponse: Codable {
    let success: Bool
    let message: String
}

