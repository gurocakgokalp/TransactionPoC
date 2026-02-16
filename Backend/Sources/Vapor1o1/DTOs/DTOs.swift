//
//  DTOs.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor

struct handshakeRequest: Content {
    let deviceId: String
}

struct enrollRequest: Content {
    let clientPublicKey: String
    let clientSignPublicKey: String
    let deviceId: String
}

struct handshakeResponse: Content {
    let serverPublicKey: String
    let status: String
    let salt: String
    let message: String
}

struct encryptedRequest: Content {
    let ciphertext: String
    let signature: String
    let nonce: String
    let tag: String
    let deviceID: String
}

struct decryptResponse: Content {
    let status: String
    let message: String
}

struct enrollResponse: Content {
    let success: Bool
    let message: String
}
