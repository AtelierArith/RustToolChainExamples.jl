# cargo_example

Cargoを使用してRustプロジェクトをビルドし、Juliaから実行する例です。

## 概要

このサンプルは、Cargoで管理されたRustプロジェクトをJuliaからビルド・実行する方法を示します。

## プロジェクト構造

```
cargo_example/
├── Cargo.toml    # Rustプロジェクトの設定
├── Project.toml  # Juliaプロジェクトの設定
├── run.jl        # 実行スクリプト
└── src/
    └── main.rs   # Rustのメインコード
```

## 使い方

### 実行

```bash
julia run.jl
```

または、Julia REPLから：

```julia
include("run.jl")
```

## 動作の仕組み

1. `RustToolChain.jl`の`cargo()`関数を使用してCargoコマンドを取得
2. `cargo build --release`でRustプロジェクトをビルド
3. ビルドされたバイナリを実行

## 依存関係

- `RustToolChain.jl` - Rust toolchainの管理

## 関連プロジェクト

- `rustc_example/` - rustcを直接使用する例
- `calcpi-rs/` - より複雑なライブラリプロジェクトの例
