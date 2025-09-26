
import SwiftUI
import FoundationModels

struct ContentView: View {
    @State private var userInput = ""      // ① ユーザー入力
    @State private var output = ""         // ② モデルからの返答
    @State private var isLoading = false   // ③ 送信中フラグ
    private let session = LanguageModelSession()  // ④ セッションを一度だけ生成

    var body: some View {
        VStack(spacing: 12) {
            // 入力欄
            TextEditor(text: $userInput)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

            // 送信ボタン
            Button(action: sendPrompt) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("送信")
                        .bold()
                }
            }
            .disabled(isLoading || userInput.isEmpty)
            .padding()

            Divider()

            // 出力欄
            ScrollView {
                Text(output)
                    .padding()
            }
        }
        .padding(.top)
    }

    // MARK: - プロンプト送信処理
    private func sendPrompt() {
        Task {
            guard SystemLanguageModel.default.availability == .available else {
                output = "モデルが利用できません"
                return
            }
            isLoading = true
            do {
                let response = try await session.respond(to: userInput)
                output = response.content          // ← .content で文字列を取得
            } catch {
                output = "エラー：\(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

