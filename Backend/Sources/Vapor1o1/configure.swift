import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.lifecycle.use(KeySetup())

    struct KeySetup: LifecycleHandler {
        func didBoot(_ application: Application) throws {
            KeyManager.shared.createServerPrivateKey()
        }
    }
    
    // register routes
    try routes(app)
}
