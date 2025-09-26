# AppleAiApp - オンデバイスLLM実装ガイド

## コード内のAPI部分と役割

### 重要なAPI部分
- `private let session = LanguageModelSession()` - LLMセッション生成
- `SystemLanguageModel.default.availability` - モデル利用可否チェック
- `session.respond(to: userInput)` - **実際のLLM呼び出し**（最重要）
- `response.content` - レスポンステキスト取得

### 各部分の役割
- **セッション管理**: LLMとの会話状態を保持
- **可用性チェック**: デバイスでLLMが使用可能か確認
- **プロンプト送信**: ユーザー入力をLLMに送信
- **レスポンス処理**: LLMからの返答を取得・表示

## Foundation Models vs Core ML 比較

### 概要
- **Foundation Models**: LLM専用の高レベルAPI。AppleのオンデバイスLLMが内蔵済み
- **Core ML**: 汎用機械学習フレームワーク。画像認識、音声処理、予測モデルなど何でも対応

### 詳細比較

| 項目 | Foundation Models | Core ML |
|------|------------------|---------|
| **難易度** | 簡単（3行で完成） | 複雑（手動実装多数） |
| **モデル** | Apple提供のみ | 任意（Llama、GPT等） |
| **カスタマイズ** | プロンプトのみ | 完全自由 |
| **ファインチューニング** | 不可 | 可能 |
| **RAG実装** | 困難 | 可能 |
| **商用利用** | 制限あり | 自由度高 |
| **メンテナンス** | Apple任せ | 自己管理 |

### 実行エンジン
両方とも **Neural Engine + GPU + CPU** で自動実行
- Foundation Models: システム自動選択
- Core ML: ある程度の指定可能

## 機能拡張時のカスタマイズポイント

### 1. ファインチューニング実装
**対象**: `sendPrompt()` 関数内
```swift
// 現在
let response = try await session.respond(to: userInput)

// 拡張後
let customModel = try MLModel(contentsOf: fineTunedModelURL)
let response = try await customModel.predict(userInput)
```

### 2. RAG（検索拡張生成）実装
**対象**: プロンプト処理部分
```swift
private func sendPrompt() {
    // RAG: 関連情報検索
    let context = await searchRelevantContext(userInput)
    
    // プロンプト強化
    let enhancedPrompt = buildPromptWithContext(userInput, context)
    
    let response = try await session.respond(to: enhancedPrompt)
}
```

### 3. 複数AIモデル切り替え
**対象**: セッション管理部分
```swift
// 現在
private let session = LanguageModelSession()

// 拡張後
private var sessions: [String: LanguageModelSession] = [:]
private var currentModel = "default"

func switchModel(to modelName: String) {
    currentModel = modelName
}
```

### 4. ストリーミングレスポンス
**対象**: レスポンス処理部分
```swift
// 現在
output = response.content

// 拡張後
for await chunk in response.stream {
    output += chunk
}
```

### 5. プロンプトテンプレート
**対象**: プロンプト前処理
```swift
private func buildSystemPrompt() -> String {
    return """
    あなたは専門的なAIアシスタントです。
    以下の文脈で回答してください：
    \(contextData)
    
    質問: \(userInput)
    """
}
```

## 開発戦略

### Phase 1: プロトタイプ
Foundation Modelsで高速プロトタイピング

### Phase 2: カスタマイズ
必要に応じてCore MLに移行
- 特定用途のファインチューニング
- RAG実装
- 複数モデル対応

### Phase 3: 最適化
パフォーマンス調整とユーザー体験向上
