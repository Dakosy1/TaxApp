//import Foundation
//import RealmSwift
//
//class ChatStorageService {
//    static let shared = ChatStorageService()
//    private let realm = try! Realm()
//    
//    func saveMessage(_ message: Message) {
//        let realmMessage = ChatMessage(message: message)
//        try? realm.write {
//            realm.add(realmMessage, update: .modified)
//        }
//    }
//    
//    func loadMessages() -> [Message] {
//        let realmMessages = realm.objects(ChatMessage.self).sorted(byKeyPath: "createdAt")
//        return realmMessages.map { Message(from: $0 as! Decoder) }
//    }
//    
//    func deleteAllMessages() {
//        try? realm.write {
//            realm.deleteAll()
//        }
//    }
//} 
