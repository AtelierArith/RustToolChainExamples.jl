# RustToolChainExamples.jl

このリポジトリは、JuliaからRustコードを呼び出す方法を示すサンプルプロジェクトのコレクションです。

## プロジェクト構成

### メインプロジェクト

- **`calcpi-rs/`** - Rustで実装されたMonte Carlo法によるπ計算ライブラリ
- **`CalcPi.jl/`** - `calcpi-rs`をJuliaから呼び出すためのJuliaパッケージ

### サンプルプロジェクト

- **`cargo_example/`** - Cargoを使ったRustプロジェクトの例
- **`rustc_example/`** - rustcを直接使ったRustプロジェクトの例

## セットアップ

### 前提条件

- Julia 1.6以上
- Rust toolchain (rustc, cargo)
- [RustToolChain.jl](https://github.com/AtelierArith/RustToolChain.jl) パッケージ

### インストール

```julia
using Pkg
Pkg.add("RustToolChain")
```

## 使い方

各サンプルプロジェクトのREADMEを参照してください。

## ライセンス

このプロジェクトのライセンス情報については、各サブディレクトリのREADMEを参照してください。
