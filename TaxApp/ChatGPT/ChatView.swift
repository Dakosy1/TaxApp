import SwiftUI

struct ChatView: View {
    @ObservedObject var VM = ChatViewModel()
    
    var body: some View {
        VStack{
            ScrollView{
                ForEach(VM.messages.filter({$0.role != .system}), id: \.id){ message in
                    messageView(message: message)
                }
            }
            HStack{
                TextField("Enter the message...", text: $VM.currentInput)
                Button{
                    VM.sendMessage()
                } label: {
                    Text("Send")
                }
            }
        }
        .padding()
    }
    
    func messageView(message: Message) -> some View{
        HStack{
            if message.role == .user{ Spacer() }
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
            if message.role == .assistant{ Spacer() }
        }
    }
}

#Preview {
    ChatView()
}
