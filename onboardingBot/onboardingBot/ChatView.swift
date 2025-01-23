////
////  ChatView.swift
////  onboardingBot
////
////  Created by Lucie Hrbkova on 17/01/2025.
////
//
//import SwiftUI
//
////struct ChatMessage: Identifiable {
////    let id = UUID()
////    let text: String
////    let isUser: Bool
////}
//
//struct ChatView: View {
//    @State private var messages: [ChatMessage] = []
//    @State private var userInput: String = ""
//    
//    var body: some View {
//            VStack {
//                ScrollView {
//                    ForEach(messages) { message in
//                        HStack {
//                            if message.isUser {
//                                Spacer()
//                                Text(message.text)
//                                    .padding()
//                                    .background(Color.blue)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                                    .frame(maxWidth: 250, alignment: .trailing)
//                            } else {
//                                Text(message.text)
//                                    .padding()
//                                    .background(Color.gray.opacity(0.2))
//                                    .cornerRadius(10)
//                                    .frame(maxWidth: 250, alignment: .leading)
//                                Spacer()
//                            }
//                        }
//                        .padding(message.isUser ? .leading : .trailing, 50)
//                        .padding(.vertical, 5)
//                    }
//                }
//                .padding()
//
//                HStack {
//                    TextField("Type your message", text: $userInput)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    Button(action: sendMessage) {
//                        Text("Send")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//            }
//        }
//
//        func sendMessage() {
//            guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//
//            let userMessage = ChatMessage(text: userInput, isUser: true)
//            messages.append(userMessage)
//            userInput = ""
//
//            // Simulate chatbot response
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                let botResponse = ChatMessage(text: generateResponse(for: userMessage.text), isUser: false)
//                messages.append(botResponse)
//            }
//        }
//
//        func generateResponse(for message: String) -> String {
//            // Basic response logic (you can replace this with a more advanced AI model)
//            if message.lowercased().contains("hello") {
//                return "Hi there! How can I assist you today?"
//            } else if message.lowercased().contains("how are you") {
//                return "I'm just a chatbot, but I'm here to help!"
//            } else {
//                return "I'm not sure about that, but let me know if you have another question."
//            }
//        }
//}
//
//#Preview {
//    ChatView()
//}
