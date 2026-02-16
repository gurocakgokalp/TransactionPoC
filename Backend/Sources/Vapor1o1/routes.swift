import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "server online, working"
    }
    
    /*
    app.get("key") { req async -> String in
        guard let key = KeyManager.shared.getServerPrivateKey() else {
            return "no exist key"
        }
        return "key alindi, \(key.rawRepresentation)"
    }
    */
    
    try app.register(collection: BankController())
}
