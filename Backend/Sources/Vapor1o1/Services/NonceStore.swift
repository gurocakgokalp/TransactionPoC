//
//  NonceStore.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 29.03.2026.
//
import Vapor

actor NonceStore {
    static let shared = NonceStore()
    
    private init() {}
    
    private var usedNonces: Set<String> = []

    func checkAndInsert(_ nonce: String) -> Bool {
        if usedNonces.contains(nonce) { return false }
        usedNonces.insert(nonce)
        return true
    }
}
