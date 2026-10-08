# TanaCount（棚卸カウンター）— B1

小規模店舗向けの棚卸アプリ。品目ごとに＋/−で数え、JANバーコードを読み取って自動で+1する。
無料で数える・読み取るまで使え、CSV書き出しを買い切りの「プロ版」で解放する。

## 構成
```
project.yml            XcodeGenの定義（.xcodeprojはここから生成する）
TanaCount.storekit     ローカル購入テスト用（プロ版 ¥480 は仮の価格）
TanaCount/Models       Item（SwiftData）
TanaCount/Services     JAN正規化・チェックデジット、CSV書き出し（BOM付きUTF-8・CRLF）、ProStore（StoreKit 2）
TanaCount/Views        一覧、連続スキャン、品目編集、課金画面
TanaCountTests         Swift Testing
```

## 開発
- プロジェクト生成: `xcodegen generate`（ファイルを追加・削除したら再実行）
- ビルド: `xcodebuild -project TanaCount.xcodeproj -scheme TanaCount -destination 'generic/platform=iOS Simulator' -derivedDataPath build build`
- テスト: `xcodebuild test -project TanaCount.xcodeproj -scheme TanaCount -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build`
- カメラ読み取りは実機のみで使える。シミュレータではスキャン画面の手入力欄で確認する（キーボードとして動く外付けスキャナも同じ欄で使える）

## 未決定・公開前にやること
- プロ版の価格（仮 ¥480）とApp Store Connectでの商品登録
- Apple Developer登録（約1.3〜1.5万円、予算超過のため成果物を見て判断）
- 実機での読み取り確認（無料のApple IDでも7日間は実機で動かせる）
