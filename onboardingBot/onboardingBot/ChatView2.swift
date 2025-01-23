//
//  ChatView2.swift
//  onboardingBot
//
//  Created by Lucie Hrbkova on 17/01/2025.
//
//import SwiftUI
//import UniformTypeIdentifiers
//
//struct ChatMessage: Identifiable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool
//}
//
//struct ChatView2: View {
//    @State private var messages: [ChatMessage] = []
//    @State private var userInput: String = ""
//    @State private var isDocumentPickerPresented: Bool = false
//
//    var body: some View {
//        VStack {
//            VStack {
//                Text("Chatbot")
//                    .font(.title)
////                    .fontWeight(.bold)
////                    .padding()
//
//                ScrollView {
//                    VStack(alignment: .leading) {
//                        ForEach(messages) { message in
//                            HStack {
//                                if message.isUser {
//                                    Spacer()
//                                    Text(message.text)
//                                        .padding()
//                                        .background(Color.blue)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(15)
//                                        .frame(maxWidth: 250, alignment: .trailing)
//                                } else {
//                                    Text(message.text)
//                                        .padding()
//                                        .background(Color.gray.opacity(0.2))
//                                        .cornerRadius(15)
//                                        .frame(maxWidth: 250, alignment: .leading)
//                                    Spacer()
//                                }
//                            }
//                            .padding(message.isUser ? .leading : .trailing, 50)
//                            .padding(.vertical, 5)
//                        }
//                    }
//                }
////                .padding()
////                .background(Color(UIColor.systemGroupedBackground))
////                .cornerRadius(20)
////                .shadow(radius: 5)
//                .frame(maxWidth: .infinity) // Make ScrollView full width
//            }
//            .padding()
//
//                HStack {
//                    Button(action: {
//                        isDocumentPickerPresented = true
//                    }) {
//                        Image(systemName: "plus")
//                            .font(.system(size: 24))
//                            .padding(.horizontal, 7.5)
//                            .padding(.vertical, 8)
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(50)
//                    }
//                    .sheet(isPresented: $isDocumentPickerPresented) {
//                        DocumentPicker { result in
//                            switch result {
//                            case .success(let text):
//                                let botResponse = ChatMessage(text: "Received document content: \(text)", isUser: false)
//                                messages.append(botResponse)
//                            case .failure(let error):
//                                let botResponse = ChatMessage(text: "Failed to load document: \(error.localizedDescription)", isUser: false)
//                                messages.append(botResponse)
//                            }
//                        }
//                    }
//
//                    HStack {
//                        TextField("Type your message", text: $userInput, axis: .vertical)
//                            .lineLimit(nil)
////                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//
//                        Button(action: sendMessage) {
//                            Image(systemName: "arrow.up")
//                                .font(.system(size: 16))
//                                .padding(.horizontal, 7)
//                                .padding(.vertical, 6)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(50)
//                        }
//                        
//                    }
//                    .padding(10)
//                    .overlay(RoundedRectangle(cornerRadius: 18)
//                            .stroke(Color.gray, lineWidth: 1)
//                    )
////                    .background(Color.cyan)
////                    .cornerRadius(18)
//                }
//                .padding()
//            }
//        }
//
//    func sendMessage() {
//         guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//         appendUserMessage()
//         sendUserInputToBackend()
//     }
//    
//    func appendUserMessage() {
//           let userMessage = ChatMessage(text: userInput, isUser: true)
//           messages.append(userMessage)
//           userInput = ""
//       }
//    
//    func sendUserInputToBackend() {
//            let url = URL(string: "http://localhost:3000/chat")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let requestBody: [String: Any] = ["message": userInput] // Use userInput directly
//            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        let botResponse = ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false)
//                        messages.append(botResponse)
//                    }
//                    return
//                }
//
//                guard let data = data,
//                      let response = try? JSONDecoder().decode([String: String].self, from: data),
//                      let botReply = response["response"] else {
//                    DispatchQueue.main.async {
//                        let botResponse = ChatMessage(text: "Failed to parse response from server.", isUser: false)
//                        messages.append(botResponse)
//                    }
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    let botResponse = ChatMessage(text: botReply, isUser: false)
//                    messages.append(botResponse)
//                }
//            }.resume()
//        }
//}
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    typealias Callback = (Result<String, Error>) -> Void
//    var callback: Callback
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(callback: callback)
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
//
//        init(callback: @escaping Callback) {
//            self.callback = callback
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else {
//                callback(.failure(NSError(domain: "DocumentPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file selected"])))
//                return
//            }
//
//            do {
//                let fileData = try Data(contentsOf: url)
//                let base64Encoded = fileData.base64EncodedString()
//
//                // Upload to backend
//                let uploadURL = URL(string: "http://localhost:3000/image")!
//                var request = URLRequest(url: uploadURL)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//                let requestBody: [String: Any] = ["image": base64Encoded]
//                request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
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
//    ChatView2()
//}
