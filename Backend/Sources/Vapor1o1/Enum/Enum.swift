//
//  Enum.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 10.02.2026.
//
import Vapor

enum CryptoError: Error {
    case b64decoding
    case b64encoding
    case sealedBoxCreating(String)
    case dbAccess
}

enum HandshakeError: Error {
    case noExistPrivateKey
}

