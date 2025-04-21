import SwiftUI

struct ChatView: View {
    @ObservedObject var VM = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(VM.messages.filter({$0.role != .system}), id: \.id) { message in
                    messageView(message: message)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                TextField("Enter the message...", text: $VM.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    VM.sendMessage()
                } label: {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color(UIColor.systemBlue.withAlphaComponent(0.3)) : Color.gray.opacity(0.2))
                .cornerRadius(12)
            if message.role == .assistant { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatView()
}
