//struct Message: Decodable {
//    let id: UUID
//    let role: SenderRole
//    let content: String
//    let createdAt: Date
//    
//    init(id: UUID = UUID(), role: SenderRole, content: String, createdAt: Date = Date()) {
//        self.id = id
//        self.role = role
//        self.content = content
//        self.createdAt = createdAt
//    }
//    
//    init(realmMessage: ChatMessage) {
//        self.id = UUID(uuidString: realmMessage.id) ?? UUID()
//        self.role = SenderRole(rawValue: realmMessage.role) ?? .user
//        self.content = realmMessage.content
//        self.createdAt = realmMessage.createdAt
//    }
//} 
