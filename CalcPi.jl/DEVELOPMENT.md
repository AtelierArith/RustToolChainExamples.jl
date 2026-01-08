# CalcPi.jl 開発ガイド

このドキュメントは`CalcPi.jl`の開発方法を説明します。

## ディレクトリ構造

```
CalcPi.jl/
├── deps/
│   ├── build.jl          # Pkg.build()で実行されるビルドスクリプト
│   ├── Project.toml      # ビルドスクリプトの依存関係
│   ├── README.md         # deps/の説明
│   └── libcalcpi_rs.*    # ビルドされたライブラリ（自動生成）
├── utils/
│   ├── generate_C_API.jl # C-APIバインディング生成スクリプト
│   ├── generator.toml    # Clang.jl設定
│   ├── prologue.jl       # 生成コードのプロローグ
│   └── Project.toml      # Clang.jl依存関係
└── src/
    ├── C_API.jl          # 自動生成されたC-APIバインディング
    └── CalcPi.jl         # 高レベルAPIラッパー
```

## 開発ワークフロー

### 1. Rustコードの変更

`calcpi-rs`のRustコードを変更した場合：

```bash
cd calcpi-rs
# Rustコードを編集
```

### 2. Juliaパッケージの再ビルド

```bash
cd CalcPi.jl
julia --project=. deps/build.jl
```

または、`Pkg.build()`を使用：

```julia
using Pkg
Pkg.build("CalcPi")
```

これにより：
- Rustライブラリがビルドされる（`cargo build --release`）
- `deps/libcalcpi_rs.dylib`（または`.so`/`.dll`）がコピーされる
- `src/C_API.jl`が再生成される

### 3. 動作確認

```julia
using CalcPi
calc = CalcPi.MonteCarloPi()
result = CalcPi.calculate(calc, UInt64(1000000))
println("π ≈ $result")
CalcPi.release(calc)
```

## ライブラリのロード優先順位

`prologue.jl`（`C_API.jl`に含まれる）は、以下の順序でライブラリを探します：

1. **`deps/libcalcpi_rs.*`** （最高優先度）
   - `Pkg.build()`でコピーされたローカルビルド
   - 開発時に使用

2. **`calcpi-rs/target/release/libcalcpi_rs.*`**
   - 直接ビルドされたライブラリ
   - `deps/`にない場合のフォールバック

3. **システムライブラリ**
   - `Libdl.find_library(["libcalcpi_rs"])`
   - システムパスから検索

## トラブルシューティング

### エラー: CEnum not found

生成された`C_API.jl`に`using CEnum`が含まれている場合、`build.jl`の後処理で削除されます。手動で削除する場合：

```julia
# src/C_API.jl から以下の行を削除
using CEnum: CEnum, @cenum
```

### エラー: libcalcpi_rs not found

ライブラリが見つからない場合：

```bash
# 1. Rustライブラリをビルド
cd calcpi-rs
cargo build --release

# 2. Juliaパッケージを再ビルド
cd ../CalcPi.jl
julia --project=. deps/build.jl
```

### クリーンビルド

完全にクリーンな状態から再ビルドする場合：

```bash
# 1. deps/をクリア
rm -rf CalcPi.jl/deps/libcalcpi_rs.*

# 2. Rustプロジェクトをクリーンビルド
cd calcpi-rs
cargo clean
cargo build --release

# 3. Juliaパッケージを再ビルド
cd ../CalcPi.jl
julia --project=. deps/build.jl
```

## 自動生成の仕組み

### C-APIバインディング生成

`utils/generate_C_API.jl`が`calcpi.h`からJuliaバインディングを自動生成します：

1. Clang.jlでCヘッダーをパース
2. Juliaコードを生成
3. `prologue.jl`を先頭に挿入
4. `src/C_API.jl`に出力

### ビルドスクリプト

`deps/build.jl`は以下の処理を実行：

1. `calcpi-rs`ディレクトリの検出
2. Rustライブラリのビルド
3. ライブラリを`deps/`にコピー
4. C-APIバインディングの生成
5. 後処理（`CEnum`の削除など）

## 参考

- `SparseIR.jl/deps/` - 参考実装
- `SparseIR.jl/utils/` - C-API生成の参考実装
