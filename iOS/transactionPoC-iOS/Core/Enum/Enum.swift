//
//  Enum.swift
//  transactionPoC-iOS
//
//  Created by Gökalp Gürocak on 5.02.2026.
//
import Foundation

enum KeyError: Error {
    case accessControlError
    case keyGenerationFail(Error)
    case restoreError
}

enum NetworkError: Error {
    case badURL
    case serverError(String)
    case decodingError
    case unknown
}

enum CryptoError: Error {
    case combinedMissing
    case b64decoding
    case b64encoding
    case error(String)
}
