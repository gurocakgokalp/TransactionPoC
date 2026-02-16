//
//  BankStore.swift
//  Vapor1o1
//
//  Created by Gökalp Gürocak on 2.02.2026.
//
import Vapor
import struct Foundation.UUID

final class BankStore: @unchecked Sendable {
    static let shared = BankStore()
    
    // string deviceid olacak (dictiniory)
    var database: [String : UserSession] = [:] // database, normalde burda db olur gercek projelerde
    
    private init() {}

}

