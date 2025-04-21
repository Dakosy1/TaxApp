import Foundation
import RealmSwift

class ChatMessage: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var content: String
    @Persisted var role: String
    @Persisted var createdAt: Date
    
    convenience init(message: Message) {
        self.init()
        self.id = message.id.uuidString
        self.content = message.content
        self.role = message.role.rawValue
        self.createdAt = message.createdAt
    }
} 