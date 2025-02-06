import SwiftUI
import Foundation

extension ChatView{
    class ChatViewModel: ObservableObject {
        @Published var messages: [Message] = [Message(id: UUID(), role: .system, content: "You are tax ai assistant. You are allowed only to talk about taxes, helping the user to get better knowledge of law and taxes by rules Kazakhstan Repulic", createdAt: Date())]
        
        @Published var currentInput: String = ""
        
        private var openAIService = OpenAIService()
        
        func sendMessage() {
            let newMessage = Message(id: UUID(), role: .user, content: currentInput, createdAt: Date())
            messages.append(newMessage)
            currentInput = ""
            
            Task {
                do {
                    if let response = await openAIService.sendMessage(messages: messages) {
                        guard let receivedOpenAIMessage = response.choices.first?.message else {
                            print("Нет сообщения в ответе")
                            return
                        }
                        let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createdAt: Date())
                        await MainActor.run {
                            messages.append(receivedMessage)
                        }
                    } else {
                        print("Ответ от API пустой")
                    }
                } catch {
                    print("Ошибка при отправке сообщения: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct Message: Decodable{
    let id: UUID
    let role: SenderRole
    let content: String
    let createdAt: Date
}
