import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    private init() { }

    var currentUser: User?
}
