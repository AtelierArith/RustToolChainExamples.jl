# CalcPi.jl C-API 自動生成ツール

このディレクトリには、CヘッダーファイルからJuliaバインディングを自動生成するツールが含まれています。

## 概要

`SparseIR.jl/utils`の仕組みを参考に、`calcpi.h`からJuliaの`C_API.jl`を自動生成します。

## ファイル構成

- `generate_C_API.jl` - メインの生成スクリプト
- `generator.toml` - Clang.jlの設定ファイル
- `prologue.jl` - 生成コードのプロローグ（ライブラリロード処理）
- `Project.toml` - 依存関係（Clang.jl）

## 使用方法

### 1. Rustライブラリのビルド

まず、Rustライブラリをビルドしてヘッダーファイルを生成します：

```bash
cd ../../calcpi-rs
cargo build --release
```

これにより、`calcpi-rs/include/calcpi.h`が生成されます。

### 2. Juliaバインディングの生成

生成スクリプトを実行します：

```bash
cd CalcPi.jl/utils
julia generate_C_API.jl
```

デフォルトでは、`../../calcpi-rs`を探します。別のパスを指定する場合：

```bash
julia generate_C_API.jl --calcpi-rs-dir /path/to/calcpi-rs
```

### 3. 生成されるファイル

`CalcPi.jl/src/C_API.jl`が生成されます。このファイルには：

- 型定義（`calcpi_monte_carlo_pi`など）
- 定数定義（`CALCPI_SUCCESS`など）
- C関数のラッパー（`calcpi_monte_carlo_pi_new`など）

が含まれます。

## 生成スクリプトの動作

1. **コマンドライン引数の解析**: `--calcpi-rs-dir`でパスを指定可能
2. **ディレクトリの検証**: `calcpi-rs/include/calcpi.h`の存在確認
3. **Clang.jlによるパース**: Cヘッダーを解析
4. **Juliaコードの生成**: `C_API.jl`を生成
5. **プロローグの挿入**: `prologue.jl`の内容を先頭に追加

## 設定のカスタマイズ

### generator.toml

```toml
[general]
prologue_file_path = "./prologue.jl"
library_name = "libcalcpi_rs"
output_file_path = "./../src/C_API.jl"
module_name = "C_API"
export_symbol_prefixes = ["calcpi_", "CALCPI_"]
extract_c_comment_style = "doxygen"
```

### prologue.jl

ライブラリのロード処理を定義します。ローカルビルドを優先し、なければシステムライブラリを探します。

## トラブルシューティング

### エラー: calcpi.h not found

Rustライブラリをビルドしてください：

```bash
cd calcpi-rs && cargo build --release
```

### エラー: CEnum not found

生成された`C_API.jl`で`CEnum`が使われていない場合は、`using CEnum`の行を削除してください。

### 生成コードの修正

生成されたコードは自動生成なので、直接編集せずに：

1. Cヘッダーを修正して再生成
2. `prologue.jl`を修正して再生成
3. `generator.toml`の設定を変更して再生成

してください。

## 参考

- `SparseIR.jl/utils/generate_C_API.jl` - 参考実装
- [Clang.jl Documentation](https://github.com/JuliaInterop/Clang.jl)
