# rustc_example

rustcを直接使用してRustコードをコンパイルし、Juliaから実行する例です。

## 概要

このサンプルは、Cargoを使わずにrustcを直接使用してRustコードをコンパイル・実行する方法を示します。シンプルな単一ファイルのRustプログラムに適しています。

## プロジェクト構造

```
rustc_example/
├── main.rs      # Rustのソースコード
├── main.jl      # Juliaの実行スクリプト
└── Project.toml # Juliaプロジェクトの設定
```

## 使い方

### 実行

```bash
julia main.jl
```

または、Julia REPLから：

```julia
include("main.jl")
```

## 動作の仕組み

1. `RustToolChain.jl`の`rustc()`関数を使用してrustcコマンドを取得
2. `rustc main.rs`でRustコードをコンパイル（`main`という実行ファイルが生成される）
3. コンパイルされたバイナリ（`./main`）を実行

## Cargoとの違い

- **rustc**: 単一ファイルのコンパイルに適している。依存関係管理なし。
- **Cargo**: プロジェクト管理、依存関係管理、ビルドシステムを含む。

## 依存関係

- `RustToolChain.jl` - Rust toolchainの管理

## 関連プロジェクト

- `cargo_example/` - Cargoを使用する例
- `calcpi-rs/` - より複雑なライブラリプロジェクトの例
