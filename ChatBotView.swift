//
//  ChatBotView.swift
//  ReceiveData
//
//  Created by Yin Yin May Phoo on 02/01/2026.
//

import Foundation
import SwiftUI
import WebKit

struct ChatbotView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentUser: User?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Health Assistant")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.clear)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                // Chatbot WebView
                BotpressWebView(userName: currentUser?.name ?? "User")
                    .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - WebView Wrapper
struct BotpressWebView: UIViewRepresentable {
    let userName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.backgroundColor = UIColor.systemBackground
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            loadBotpress(in: webView)
        }
    }
    
    private func loadBotpress(in webView: WKWebView) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <meta charset="UTF-8">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                html, body {
                    height: 100%;
                    width: 100%;
                    overflow: hidden;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                }
                #webchat {
                    height: 100vh;
                    width: 100vw;
                }
            </style>
        </head>
        <body>
            <div id="webchat"></div>
            <script src="https://cdn.botpress.cloud/webchat/v1/inject.js"></script>
            <script>
                window.botpressWebChat.init({
                    // REPLACE THESE WITH YOUR ACTUAL BOTPRESS CREDENTIALS
                    botId: "YOUR_BOT_ID",
                    hostUrl: "https://cdn.botpress.cloud/webchat/v1",
                    messagingUrl: "https://messaging.botpress.cloud",
                    clientId: "YOUR_CLIENT_ID",
                    
                    // Customization to match your app theme
                    containerWidth: "100%",
                    layoutWidth: "100%",
                    hideWidget: true,
                    showCloseButton: false,
                    disableAnimations: false,
                    closeOnEscape: false,
                    
                    // Theme customization
                    stylesheet: 'https://webchat-styler-css.botpress.app/prod/code/9e6a7b43-0594-4984-8562-14fbdbb1e96c/v77720/style.css',
                    
                    // User information
                    userData: {
                        name: "\(userName)"
                    },
                    
                    // Custom styling
                    botName: "Health Assistant",
                    botAvatar: "https://i.imgur.com/placeholder-health-icon.png",
                    
                    // Additional config
                    enableConversationDeletion: false,
                    showPoweredBy: false
                });
                
                // Show the chat immediately
                window.botpressWebChat.sendEvent({ type: 'show' });
                
                // Optional: Send initial greeting
                setTimeout(() => {
                    window.botpressWebChat.sendEvent({
                        type: 'proactive-trigger',
                        channel: 'web',
                        payload: { text: 'Welcome! How can I help you with your health today?' }
                    });
                }, 500);
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: BotpressWebView
        
        init(_ parent: BotpressWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Botpress chat loaded successfully")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Error loading chatbot: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview
struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView(currentUser: .constant(User(
            id: "1",
            name: "John Doe",
            email: "john@example.com",
            healthProfile: nil
        )))
    }
}
