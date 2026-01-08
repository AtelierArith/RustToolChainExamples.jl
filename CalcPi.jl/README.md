# CalcPi.jl

JuliaからRustで実装されたMonte Carlo法によるπ計算ライブラリ（`calcpi-rs`）を呼び出すためのJuliaパッケージです。

## 概要

`CalcPi.jl`は、`calcpi-rs`ライブラリへのJuliaバインディングを提供します。Monte Carlo法を使用してπの値を計算できます。

## インストール

```julia
using Pkg
Pkg.add(url="path/to/CalcPi.jl")
```

または、開発モードでインストール：

```julia
using Pkg
Pkg.develop(path="path/to/CalcPi.jl")
```

## ビルド

パッケージをビルドすると、Rustライブラリが自動的にコンパイルされ、C APIバインディングが生成されます：

```julia
using Pkg
Pkg.build("CalcPi")
```

## 使い方

```julia
using CalcPi

# MonteCarloPiインスタンスを作成
calc = CalcPi.MonteCarloPi()

# 100万サンプルでπを計算
result = CalcPi.calculate(calc, UInt64(1_000_000))
println("π ≈ $result")

# リソースを解放
CalcPi.release(calc)
```

## プロジェクト構造

```
CalcPi.jl/
├── deps/
│   ├── build.jl          # ビルドスクリプト
│   └── libcalcpi_rs.*    # ビルドされたライブラリ（自動生成）
├── src/
│   ├── CalcPi.jl         # 高レベルAPI
│   └── C_API.jl           # C APIバインディング（自動生成）
├── test/                  # テストファイル
└── utils/                 # C API生成ユーティリティ
```

## 開発

開発ガイドについては`DEVELOPMENT.md`を参照してください。

## テスト

```julia
using Pkg
Pkg.test("CalcPi")
```

## 依存関係

- `CEnum.jl` - C enumのサポート
- `RustToolChain.jl` - Rust toolchainの管理（ビルド時のみ）

## ライセンス

このプロジェクトのライセンス情報については、ルートディレクトリのREADMEを参照してください。
