# calcpi-rs

Monte Carlo法を使用してπ（円周率）を計算するRustライブラリです。

## 概要

このライブラリは、Monte Carlo法を用いてπの値を推定します。ランダムに生成した点が単位円内に含まれる確率からπを計算します。

## ビルド

### 通常のビルド

```bash
cargo build --release
```

### Cヘッダーファイルの生成

ビルド時に`cbindgen`が自動的にCヘッダーファイル（`include/calcpi.h`）を生成します。

## 出力ファイル

ビルド後、以下のファイルが生成されます：

- **ライブラリファイル**:
  - Linux: `target/release/libcalcpi_rs.so`
  - macOS: `target/release/libcalcpi_rs.dylib`
  - Windows: `target/release/calcpi_rs.dll`

- **Cヘッダーファイル**: `include/calcpi.h`

## ライブラリタイプ

このプロジェクトは以下の3つのライブラリタイプを生成します：

- `cdylib` - C互換の動的ライブラリ（Juliaから呼び出すために使用）
- `staticlib` - 静的ライブラリ
- `rlib` - Rustライブラリ

## 依存関係

- `rand = "0.8"` - 乱数生成
- `cbindgen = "0.29"` - Cヘッダーファイル生成（ビルド時のみ）

## Juliaパッケージとの連携

このライブラリは`CalcPi.jl`パッケージから使用されます。詳細は`../CalcPi.jl/README.md`を参照してください。

## テスト

```bash
cargo test
```

## ライセンス

このプロジェクトのライセンス情報については、ルートディレクトリのREADMEを参照してください。
