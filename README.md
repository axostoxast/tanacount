# TanaCount（棚卸カウンター）— B1

小規模店舗向けの棚卸アプリ。品目ごとに＋/−で数え、JANバーコードを読み取って自動で+1する。
無料で数える・読み取るまで使え、CSV書き出しを買い切りの「プロ版」で解放する。

## 構成
```
project.yml            XcodeGenの定義（.xcodeprojはここから生成する）
TanaCount.storekit     ローカル購入テスト用（プロ版 ¥480）
TanaCount/Models       Item（SwiftData）
TanaCount/Services     JAN正規化・チェックデジット、CSV書き出し（BOM付きUTF-8・CRLF）、ProStore（StoreKit 2）
TanaCount/Views        一覧、連続スキャン、品目編集、課金画面
TanaCountTests         Swift Testing
TanaCount/Debug        スクリーンショット用の起動引数（DEBUGのみ。`-screenshot list|edit` でサンプル品目を表示）
scripts/make_icon.swift アプリアイコンの生成
docs/                  プライバシーポリシー、App Store掲載文、スクリーンショット
```

## 開発
- プロジェクト生成: `xcodegen generate`（ファイルを追加・削除したら再実行）
- ビルド: `xcodebuild -project TanaCount.xcodeproj -scheme TanaCount -destination 'generic/platform=iOS Simulator' -derivedDataPath build build`
- テスト: `xcodebuild test -project TanaCount.xcodeproj -scheme TanaCount -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build`
- カメラ読み取りは実機のみで使える。シミュレータではスキャン画面の手入力欄で確認する（キーボードとして動く外付けスキャナも同じ欄で使える）

## リリース
1. アーカイブ: `xcodebuild archive -project TanaCount.xcodeproj -scheme TanaCount -destination 'generic/platform=iOS' -archivePath build/TanaCount.xcarchive -allowProvisioningUpdates`
2. アップロード: `xcodebuild -exportArchive -archivePath build/TanaCount.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/export -allowProvisioningUpdates`（ビルド番号は自動で上がる）
- 署名: 個人チーム TJM8F4Z2Z2、自動署名。XcodeのSettings → AccountsにApple IDが入っている必要がある

## 未決定・公開前にやること
- App Store Connectでプロ版（¥480、2026-10-08決定）を商品登録
- 実機での読み取り確認（無料のApple IDでも7日間は実機で動かせる）
