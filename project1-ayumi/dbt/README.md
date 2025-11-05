# あゆみSaaS データ分析基盤 - dbtプロジェクト

就労支援SaaS『あゆみ』のBigQueryデータウェアハウスに対するdbt変換プロジェクト

---

## 📊 プロジェクト概要

このdbtプロジェクトは、BigQueryに格納された『あゆみ』の運用データを、分析可能な形に変換します。

### データ変換の流れ

```
Raw Data (BigQuery)
    ↓
Staging Layer (クリーニング・型変換)
    ↓
Intermediate Layer (ビジネスロジック適用)
    ↓
Marts Layer (分析用テーブル)
```

---

## 🗂️ ディレクトリ構造

```
dbt/
├── models/
│   ├── staging/           # Staging層モデル
│   │   ├── _sources.yml   # ソーステーブル定義
│   │   ├── stg_users.sql
│   │   ├── stg_attendance_records.sql
│   │   └── ...
│   ├── intermediate/      # Intermediate層モデル
│   │   ├── int_monthly_attendance.sql
│   │   └── ...
│   └── marts/             # Marts層モデル
│       ├── mart_attendance_summary.sql
│       └── ...
├── tests/                 # カスタムテスト
├── macros/                # 再利用可能なマクロ
├── seeds/                 # 静的データ（CSV）
├── snapshots/             # スナップショット定義
├── analyses/              # アドホック分析SQL
├── dbt_project.yml        # プロジェクト設定
├── profiles.yml.example   # 接続設定サンプル
└── README.md              # このファイル
```

---

## 🚀 セットアップ

### 1. dbtのインストール

```bash
pip install dbt-bigquery
```

### 2. 接続設定

`profiles.yml.example`を`~/.dbt/profiles.yml`にコピーして編集：

```bash
# Windowsの場合
copy profiles.yml.example %USERPROFILE%\.dbt\profiles.yml

# Mac/Linuxの場合
cp profiles.yml.example ~/.dbt/profiles.yml
```

### 3. 接続テスト

```bash
dbt debug
```

---

## 📝 主要コマンド

### モデルの実行

```bash
# 全モデルを実行
dbt run

# 特定のモデルのみ実行
dbt run --select stg_users

# 特定のディレクトリ配下を実行
dbt run --select staging.*

# タグでフィルタリング
dbt run --select tag:staging
```

### テストの実行

```bash
# 全テストを実行
dbt test

# 特定のモデルのテスト
dbt test --select stg_users
```

### ドキュメント生成

```bash
# ドキュメントを生成して表示
dbt docs generate
dbt docs serve
```

### その他

```bash
# 依存関係の確認
dbt list

# コンパイル（実行せずにSQLを生成）
dbt compile

# クリーンアップ
dbt clean
```

---

## 📐 データモデル設計

### Staging層（4モデル）

生データのクリーニング・型変換を行います。

| モデル | 説明 | マテリアライズ |
|--------|------|----------------|
| `stg_users` | 利用者基本情報 | View |
| `stg_attendance_records` | 出席実績 | View |
| `stg_daily_reports_morning` | 朝日報 | View |
| `stg_daily_reports_evening` | 夕日報 | View |

### Intermediate層（3モデル）

ビジネスロジックを適用します。

| モデル | 説明 | マテリアライズ |
|--------|------|----------------|
| `int_monthly_attendance` | 月次出席集計 | View |
| `int_health_metrics` | 健康指標集計 | View |
| `int_training_hours` | 訓練時間集計 | View |

### Marts層（3モデル）

最終的な分析用テーブルです。

| モデル | 説明 | マテリアライズ |
|--------|------|----------------|
| `mart_attendance_summary` | 出席サマリー | Table |
| `mart_mental_health_trend` | メンタルヘルストレンド | Table |
| `mart_training_effectiveness` | 訓練効果測定 | Table |

---

## 🧪 テスト戦略

### データ品質テスト

- **ユニークテスト**: 主キーの一意性
- **Not Nullテスト**: 必須カラムの非NULL制約
- **関連性テスト**: 外部キー制約
- **カスタムテスト**: ビジネスルールの検証

例:
```yaml
models:
  - name: stg_users
    columns:
      - name: user_id
        tests:
          - unique
          - not_null
      - name: email
        tests:
          - unique
```

---

## 📊 KPI定義

このdbtプロジェクトで計算される主要KPIです。

### 出席管理KPI
- 月次出席率: 出席日数 / 総日数 × 100
- 連続欠席日数: LAG関数で前日との差分計算
- 遅刻率: 遅刻日数 / 総日数 × 100

### メンタルヘルスKPI
- 平均ストレスレベル: 週次平均（1-3）
- 平均睡眠時間: 週次平均
- ストレス上昇トレンド: 2週連続上昇フラグ

### 訓練効果KPI
- 月次訓練時間: 合計訓練時間
- 自己評価平均: 夕日報の評価平均
- 訓練参加率: 訓練日数 / 出席日数 × 100

---

## 🔗 関連リソース

- [dbt公式ドキュメント](https://docs.getdbt.com/)
- [BigQueryアダプター](https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup)
- [プロジェクト全体README](../README.md)
- [データベース設計書](../docs/database_design.md)

---

## 📝 開発ガイドライン

### 命名規則

- **Staging**: `stg_{table_name}`
- **Intermediate**: `int_{descriptive_name}`
- **Marts**: `mart_{business_area}`

### SQLスタイル

- インデント: 2スペース
- キーワード: 大文字
- テーブル名: snake_case

### コミットメッセージ

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
test: テスト追加
refactor: リファクタリング
```

---

**最終更新**: 2025年11月5日
