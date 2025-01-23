//
//  ChatView3.swift
//  onboardingBot
//
//  Created by Lucie Hrbkova on 21/01/2025.
//
//import UniformTypeIdentifiers
//import SwiftUI
//
//struct ChatMessage: Identifiable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool
//    let image: Data?
//}
//
//struct ChatView3: View {
//    @State private var messages: [ChatMessage] = []
//    @State private var userInput: String = ""
//    @State private var isDocumentPickerPresented: Bool = false
//
//    var body: some View {
//        VStack {
//            HeaderView()
//            ChatMessagesView(messages: $messages)
//            InputAreaView(userInput: $userInput, isDocumentPickerPresented: $isDocumentPickerPresented, onSend: sendMessage)
//        }
//        .sheet(isPresented: $isDocumentPickerPresented) {
//            DocumentPicker { result in
//                handleDocumentPickerResult(result)
//            } onMessage: { newMessage in
//                messages.append(newMessage)
//            }
//        }
//    }
//
//    func sendMessage() {
//        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//        appendUserMessage()
//        sendUserInputToBackend()
//    }
//
//    func appendUserMessage() {
//        let userMessage = ChatMessage(text: userInput, isUser: true, image: nil)
//        DispatchQueue.main.async {
//            messages.append(userMessage)
//            userInput = ""
//        }
//    }
//
//    func sendUserInputToBackend() {
//        guard let url = URL(string: "http://localhost:3000/chat") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody: [String: Any] = ["message": userInput]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    let botResponse = ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false, image: nil)
//                    messages.append(botResponse)
//                }
//                return
//            }
//
//            guard let data = data,
//                  let response = try? JSONDecoder().decode([String: String].self, from: data),
//                  let botReply = response["response"] else {
//                DispatchQueue.main.async {
//                    let botResponse = ChatMessage(text: "Failed to parse response from server.", isUser: false, image: nil)
//                    messages.append(botResponse)
//                }
//                return
//            }
//
//            DispatchQueue.main.async {
//                let botResponse = ChatMessage(text: botReply, isUser: false, image: nil)
//                messages.append(botResponse)
//            }
//        }.resume()
//    }
//
//    func handleDocumentPickerResult(_ result: Result<String, Error>) {
//        DispatchQueue.main.async {
//            switch result {
//            case .success(let serverReply):
//                let botResponse = ChatMessage(text: serverReply, isUser: false, image: nil)
//                messages.append(botResponse)
//
//            case .failure(let error):
//                let errorResponse = ChatMessage(text: "Failed to process document: \(error.localizedDescription)", isUser: false, image: nil)
//                messages.append(errorResponse)
//            }
//        }
//    }
//}
//
//// Views for Header, Messages, and Input
//struct HeaderView: View {
//    var body: some View {
//        Text("Chatbot")
//            .font(.title)
//            .padding()
//    }
//}
//
//struct ChatMessagesView: View {
//    @Binding var messages: [ChatMessage]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                ForEach(messages) { message in
//                    HStack {
//                        if message.isUser {
//                            Spacer()
//                            messageView(message: message, alignment: .trailing, backgroundColor: .blue, textColor: .white)
//                        } else {
//                            messageView(message: message, alignment: .leading, backgroundColor: .gray.opacity(0.2), textColor: .black)
//                            Spacer()
//                        }
//                    }
//                    .padding(message.isUser ? .leading : .trailing, 50)
//                    .padding(.vertical, 5)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//    }
//
//    func messageView(message: ChatMessage, alignment: Alignment, backgroundColor: Color, textColor: Color) -> some View {
//        Group {
//            if let imageData = message.image, let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//            } else {
//                Text(message.text)
//                    .padding()
//                    .background(backgroundColor)
//                    .foregroundColor(textColor)
//                    .cornerRadius(15)
//                    .frame(maxWidth: 250, alignment: alignment)
//            }
//        }
//    }
//}
//
//struct InputAreaView: View {
//    @Binding var userInput: String
//    @Binding var isDocumentPickerPresented: Bool // Use binding from parent
//    var onSend: () -> Void
//
//    var body: some View {
//        HStack {
//            Button(action: {
//                isDocumentPickerPresented = true
//            }) {
//                Image(systemName: "plus")
//                    .font(.system(size: 24))
//                    .padding(.horizontal, 7.5)
//                    .padding(.vertical, 8)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(50)
//            }
//
//            HStack {
//                TextField("Type your message", text: $userInput, axis: .vertical)
//                    .lineLimit(nil)
//
//                Button(action: onSend) {
//                    Image(systemName: "arrow.up")
//                        .font(.system(size: 16))
//                        .padding(.horizontal, 7)
//                        .padding(.vertical, 6)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(50)
//                }
//            }
//            .padding(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 18)
//                    .stroke(Color.gray, lineWidth: 1)
//            )
//        }
//        .padding()
//    }
//}
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    typealias Callback = (Result<String, Error>) -> Void
//    var callback: Callback
//    var onMessage: (ChatMessage) -> Void // New closure for appending messages
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(callback: callback, onMessage: onMessage)
//    }
//
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText, .jpeg, .pdf], asCopy: true)
//        documentPicker.delegate = context.coordinator
//        return documentPicker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        var callback: Callback
//        var onMessage: (ChatMessage) -> Void // Closure to send messages back to parent
//
//        init(callback: @escaping Callback, onMessage: @escaping (ChatMessage) -> Void) {
//               self.callback = callback
//               self.onMessage = onMessage
//           }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else {
//                callback(.failure(NSError(domain: "DocumentPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file selected"])))
//                return
//            }
//
//            do {
//                let fileData = try Data(contentsOf: url)
//                
//                // Create a new message for the selected image
//                  let imageMessage = ChatMessage(text: "", isUser: true, image: fileData)
//
//                  // Send the message back to the parent view
//                  DispatchQueue.main.async {
//                      self.onMessage(imageMessage)
//                  }
//
//                
//                // Encode and send the image to the server
//                let base64Encoded = fileData.base64EncodedString()
//
//                // Upload to backend
//                let uploadURL = URL(string: "http://localhost:3000/image")!
//                var request = URLRequest(url: uploadURL)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//                let requestBody: [String: Any] = ["image": base64Encoded]
//                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//
//                URLSession.shared.dataTask(with: request) { data, response, error in
//                    if let error = error {
//                        DispatchQueue.main.async {
//                            self.callback(.failure(error))
//                        }
//                        return
//                    }
//
//                    guard let data = data,
//                          let response = try? JSONDecoder().decode([String: String].self, from: data),
//                          let serverReply = response["response"] else {
//                        DispatchQueue.main.async {
//                            self.callback(.failure(NSError(domain: "Server", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
//                        }
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        self.callback(.success(serverReply))
//                    }
//                }.resume()
//            } catch {
//                callback(.failure(error))
//            }
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            callback(.failure(NSError(domain: "DocumentPicker", code: 2, userInfo: [NSLocalizedDescriptionKey: "Document selection cancelled"])))
//        }
//    }
//}
//
//#Preview {
//    ChatView3()
//}
//
