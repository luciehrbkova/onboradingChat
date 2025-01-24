//
//  ChatView4.swift
//  onboardingBot
//
//  Created by Lucie Hrbkova on 22/01/2025.
//

import UniformTypeIdentifiers
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let image: Data?
}

struct ChatView4: View {
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var isDocumentPickerPresented: Bool = false

    var body: some View {
        VStack {
            HeaderView()
            ChatMessagesView(messages: $messages)
            InputAreaView(userInput: $userInput, isDocumentPickerPresented: $isDocumentPickerPresented, onSend: sendMessage)
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPicker { result in
                handleDocumentPickerResult(result)
            } onMessage: { newMessage in
                messages.append(newMessage)
            }
        }
        .background(
            Image("IFGL-BG")
                .resizable()
                .ignoresSafeArea(edges: .top)
                .scaledToFill()
        )
    }

    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        appendUserMessage()
        sendUserInputToBackend()
    }

    func appendUserMessage() {
        let userMessage = ChatMessage(text: userInput, isUser: true, image: nil)
        DispatchQueue.main.async {
            messages.append(userMessage)
            userInput = ""
        }
    }

    func sendUserInputToBackend() {
        guard let url = URL(string: "http://localhost:3000/chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["message": userInput]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    let botResponse = ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false, image: nil)
                    messages.append(botResponse)
                }
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode([String: String].self, from: data),
                  let botReply = response["response"] else {
                DispatchQueue.main.async {
                    let botResponse = ChatMessage(text: "Failed to parse response from server.", isUser: false, image: nil)
                    messages.append(botResponse)
                }
                return
            }

            DispatchQueue.main.async {
                let botResponse = ChatMessage(text: botReply, isUser: false, image: nil)
                messages.append(botResponse)
            }
        }.resume()
    }

    func handleDocumentPickerResult(_ result: Result<String, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let serverReply):
                let botResponse = ChatMessage(text: serverReply, isUser: false, image: nil)
                messages.append(botResponse)

            case .failure(let error):
                let errorResponse = ChatMessage(text: "Failed to process document: \(error.localizedDescription)", isUser: false, image: nil)
                messages.append(errorResponse)
            }
        }
    }
}

// Views for Header, Messages, and Input
struct HeaderView: View {
    var body: some View {
        VStack {
            Image("IFGL-Beacon")
        }
}
}

struct ChatMessagesView: View {
    @Binding var messages: [ChatMessage]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(messages) { message in
                    HStack {
                        if message.isUser {
                            Spacer()
                            messageView(message: message,
                                        alignment: .trailing,
                                        backgroundColor: Color(
                                            red: 78/255,
                                            green: 121/255,
                                            blue: 241/255),
                                        textColor: .white)
                        } else {
                            messageView(message: message,
                                        alignment: .leading,
                                        backgroundColor: Color(
                                            red: 18/255,
                                            green: 50/255,
                                            blue: 80/255),
                                        textColor: .white)
                            Spacer()
                        }
                    }
                    .padding(message.isUser ? .leading : .trailing, 50)
                    .padding(.vertical, 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding() // Keep padding outside the ScrollView
    }

    func messageView(message: ChatMessage, alignment: Alignment, backgroundColor: Color, textColor: Color) -> some View {
        Group {
            if let imageData = message.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(24)
                    .frame(width: 200)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
            
                    )
            } else {
                HStack {
                    if alignment == .leading{
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.system(size: 16))
                            .foregroundColor(backgroundColor)
                            .padding(.zero)
                    }
                    Text(message.text)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 13)
                        .background(
                           ZStack(alignment: alignment) {
                               RoundedRectangle(cornerRadius: 15)
                                   .fill(backgroundColor)
                           }
                       )
                       .foregroundColor(textColor)
                       .frame(maxWidth: 250, alignment: alignment)
                       .offset(x: alignment == .leading ? -13 : 11, y: 0)
                    if alignment == .trailing{
                        Image(systemName: "arrowtriangle.right.fill")
                            .font(.system(size: 16))
                            .foregroundColor(backgroundColor)
                            .padding(.zero)
                    }
                }
                
           }
        }
    }
}

struct InputAreaView: View {
    @Binding var userInput: String
    @Binding var isDocumentPickerPresented: Bool // Use binding from parent
    var onSend: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                isDocumentPickerPresented = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .padding(14)
                    .foregroundColor(.white)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            
            ZStack(alignment: .trailing) { // Container for text field and send button
                TextField("Type your message", text: $userInput, axis: .vertical)
                    .foregroundColor(Color(red: 104/255, green: 126/255, blue: 153/255) )
                    .lineLimit(nil)
                    .padding(14)
                    .accentColor(Color(red: 104/255, green: 126/255, blue: 153/255))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 2/255, green: 19/255, blue: 34/255))
                    )
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Color(red: 78/255, green: 121/255, blue: 241/255))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding(.trailing, 15)
            }
            
        }
        .padding()
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    typealias Callback = (Result<String, Error>) -> Void
    var callback: Callback
    var onMessage: (ChatMessage) -> Void // New closure for appending messages
    
    func makeCoordinator() -> Coordinator {
        Coordinator(callback: callback, onMessage: onMessage)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText, .jpeg, .pdf], asCopy: true)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var callback: Callback
        var onMessage: (ChatMessage) -> Void // Closure to send messages back to parent

        init(callback: @escaping Callback, onMessage: @escaping (ChatMessage) -> Void) {
               self.callback = callback
               self.onMessage = onMessage
           }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                callback(.failure(NSError(domain: "DocumentPicker", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file selected"])))
                return
            }

            do {
                let fileData = try Data(contentsOf: url)
                
                // Create a new message for the selected image
                  let imageMessage = ChatMessage(text: "", isUser: true, image: fileData)

                  // Send the message back to the parent view
                  DispatchQueue.main.async {
                      self.onMessage(imageMessage)
                  }

                
                // Encode and send the image to the server
                let base64Encoded = fileData.base64EncodedString()

                // Upload to backend
                let uploadURL = URL(string: "http://localhost:3000/image")!
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let requestBody: [String: Any] = ["image": base64Encoded]
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.callback(.failure(error))
                        }
                        return
                    }

                    guard let data = data,
                          let response = try? JSONDecoder().decode([String: String].self, from: data),
                          let serverReply = response["response"] else {
                        DispatchQueue.main.async {
                            self.callback(.failure(NSError(domain: "Server", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.callback(.success(serverReply))
                    }
                }.resume()
            } catch {
                callback(.failure(error))
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            callback(.failure(NSError(domain: "DocumentPicker", code: 2, userInfo: [NSLocalizedDescriptionKey: "Document selection cancelled"])))
        }
    }
}

#Preview {
    ChatView4()
}

