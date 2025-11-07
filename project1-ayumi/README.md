# プロジェクト1: 就労支援SaaS『あゆみ』データ分析基盤

![Status](https://img.shields.io/badge/Status-Phase%201~3%20Complete-success)
![dbt](https://img.shields.io/badge/dbt-11%20models-blue)
![Tests](https://img.shields.io/badge/tests-29%20passed-brightgreen)
![Dashboard](https://img.shields.io/badge/Looker%20Studio-Live-orange)

就労移行支援事業所向けSaaS『あゆみ』の運用データを活用したデータ分析基盤の構築プロジェクト

---

## 🎯 プロジェクト概要

### 目的

1. **データドリブンな支援の質向上**
   - 利用者の出席率・メンタルヘルスをリアルタイム監視
   - 早期介入が必要な利用者を自動検出

2. **経営判断のための可視化**
   - 事業所の稼働率・KPI可視化
   - データに基づく支援計画の最適化

3. **技術スキルの証明**
   - MySQL → BigQuery のELT実装
   - dbt によるデータモデリング
   - Looker Studio によるダッシュボード構築

---

## 💡 差別化ポイント

### ビジネス視点

- ✅ **実務経験に基づく設計**: 現職での課題を実際に解決
- ✅ **福祉×データという希少性**: 教育・福祉領域のデータ分析経験
- ✅ **社会貢献性**: 障害者の就労支援という社会的意義

### 技術視点

- ✅ **Laravel → MySQL → BigQuery の実装**: アプリケーションDBからDWHへのETL
- ✅ **dbt によるデータ変換**: 11モデルの実装とテスト
- ✅ **セキュリティ・コンプライアンス対応**: GDPR対応、監査ログ、個人情報保護

### ストーリー性

- ✅ **明確なビジョン**: 「データで支援の質を向上させる」
- ✅ **現職での実践経験**: 実際に使っているシステム
- ✅ **ポートフォリオとしての説得力**: 単なる学習ではなく、実課題の解決

---

## 🛠️ 技術スタック

| レイヤー | 技術 | 用途 |
|---------|------|------|
| Application | Laravel 10.x (PHP 8.2) | SaaSアプリケーション本体 |
| Operational DB | MySQL 8.0 | トランザクション処理 |
| ETL/ELT | 日次バッチ / Cloud Composer | データ転送 |
| Data Warehouse | Google BigQuery | 分析用DWH |
| Data Transformation | dbt (data build tool) | データモデリング |
| Data Visualization | Looker Studio | ダッシュボード |
| Version Control | Git/GitHub | コード管理 |

---

## 📐 システムアーキテクチャ

```
┌──────────────────────────┐
│   Laravel Application    │
│  (就労支援SaaS『あゆみ』) │
│                          │
│  ┌────────────────────┐ │
│  │  利用者・スタッフ   │ │
│  │     Web UI         │ │
│  └─────────┬──────────┘ │
│            │ CRUD        │
└────────────┼─────────────┘
             │
             ▼
┌─────────────────────────────────┐
│      MySQL (Production DB)      │
│                                 │
│  ┌───────────────────────────┐ │
│  │  Core Tables              │ │
│  │  - users                  │ │
│  │  - attendance_records     │ │
│  │  - daily_reports_morning  │ │
│  │  - daily_reports_evening  │ │
│  └───────────┬───────────────┘ │
└──────────────┼───────────────────┘
               │ Daily ETL (23:00)
               ▼
┌──────────────────────────────────────┐
│     Google BigQuery (DWH)            │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  Raw Layer                      │ │
│  │  - raw_users                    │ │
│  │  - raw_attendance_records       │ │
│  └──────────┬─────────────────────┘ │
│             │ dbt source()           │
│  ┌──────────▼─────────────────────┐ │
│  │  Staging Layer                  │ │
│  │  - stg_users                    │ │
│  │  - stg_attendance_records       │ │
│  └──────────┬─────────────────────┘ │
│             │ dbt ref()              │
│  ┌──────────▼─────────────────────┐ │
│  │  Intermediate Layer             │ │
│  │  - int_monthly_attendance       │ │
│  │  - int_health_metrics           │ │
│  └──────────┬─────────────────────┘ │
│             │ dbt ref()              │
│  ┌──────────▼─────────────────────┐ │
│  │  Mart Layer                     │ │
│  │  - mart_attendance_summary      │ │
│  │  - mart_mental_health_trend     │ │
│  └──────────┬─────────────────────┘ │
└─────────────┼───────────────────────┘
              │ SQL Query
              ▼
     ┌────────────────────┐
     │  Looker Studio     │
     │  Dashboard (3種類) │
     └────────────────────┘
```

詳細なアーキテクチャ図とデータフロー説明は [こちら](docs/architecture.md) を参照してください。

---

## ✅ 実装状況

### Phase 1: Staging Layer (完了 ✅ 2025年10月完了)
- ✅ `stg_users`: 利用者マスタ (個人情報マスク)
- ✅ `stg_staffs`: スタッフマスタ  
- ✅ `stg_attendance_records`: 出席記録
- ✅ `stg_daily_reports_morning`: 朝日報 (睡眠・食事・ストレス)
- ✅ `stg_daily_reports_evening`: 夕日報 (訓練内容・自己評価)

**合計**: 5モデル実装完了

**処理内容**:
- カラム名の標準化
- データ型の統一
- 論理削除レコードの除外
- タイムゾーン調整 (Asia/Tokyo)

### Phase 2: Intermediate Layer (完了 ✅ 2025年10月完了)
- ✅ `int_user_monthly_attendance`: 月次出席集計 (出席率・遅刻率計算)
- ✅ `int_user_relationships`: 利用者-担当者関係
- ✅ `int_daily_health_metrics`: 日次健康指標 (睡眠・ストレス週次集計)

**合計**: 3モデル実装完了

**処理内容**:
- 出席率・遅刻率の計算
- 健康指標の週次集計
- 訓練時間の月次集計

### Phase 3: Marts Layer (完了 ✅ 2025年10月完了)
- ✅ `mart_user_attendance_summary`: 出席サマリー (経営ダッシュボード用)
- ✅ `mart_staff_support_metrics`: スタッフ支援指標
- ✅ `mart_program_effectiveness`: プログラム効果測定

**合計**: 3モデル実装完了

**KPI**:
- 出席率: 90%以上を優良
- ストレスレベル: 3.0以下を維持
- 訓練時間: 月60時間以上

### データ品質管理 (完了 ✅)
- **dbtテスト**: 29個全てPASS
- **テストカバレッジ**: 
  - Primary Key uniqueness
  - Not Null constraints
  - Referential integrity
  - Business logic validation

### 可視化 (完了 ✅ 2025年10月28日完了)
- **Looker Studio**: 3ページダッシュボード完成
  - [📊 ダッシュボードを見る](https://lookerstudio.google.com/reporting/314e9b61-8c65-4adb-92ca-2fd9a6b5e171)

---

## 🗄️ データベース設計

### 主要テーブル（10テーブル）

| テーブル名 | 行数（サンプル） | 説明 |
|-----------|-----------------|------|
| users | 25 | 利用者マスタ（個人情報は暗号化） |
| staffs | 5 | スタッフマスタ（RBAC対応） |
| attendance_plans | - | 出席予定 |
| attendance_records | 1,650 | 出席実績（承認ワークフロー） |
| daily_reports_morning | 1,449 | 朝日報（睡眠・食事・ストレス） |
| daily_reports_evening | 1,449 | 夕日報（訓練内容・自己評価） |
| interviews | - | 面談記録 |
| audit_logs | - | 監査ログ（GDPR対応） |
| holidays | - | 祝日マスタ |
| settings | - | 設定マスタ |

詳細: [docs/database_design.md](./docs/database_design.md)

---

## 📊 dbtモデル構成

### Staging層（5モデル）
- `stg_users`: 利用者基本情報（個人情報マスク）
- `stg_staffs`: スタッフ基本情報
- `stg_attendance_records`: 出席実績
- `stg_daily_reports_morning`: 朝日報
- `stg_daily_reports_evening`: 夕日報

### Intermediate層（3モデル）
- `int_user_monthly_attendance`: 月次出席集計
- `int_user_relationships`: 利用者-担当者関係
- `int_daily_health_metrics`: 健康指標の集計（睡眠・ストレス）

### Mart層（3モデル）
- `mart_user_attendance_summary`: 出席サマリー（経営ダッシュボード用）
- `mart_staff_support_metrics`: スタッフ支援指標
- `mart_program_effectiveness`: プログラム効果測定

---

## 📈 分析指標（KPI）

### 1. 出席管理KPI

| 指標 | 定義 | 目標値 | 用途 |
|------|------|--------|------|
| 月次出席率 | 出席日数 / 総日数 × 100 | 90%以上 | 利用者のエンゲージメント測定 |
| 連続欠席日数 | 連続で欠席した日数 | 3日未満 | 早期介入が必要な利用者の検出 |
| 遅刻率 | 遅刻日数 / 総日数 × 100 | 10%以下 | 生活リズムの安定度測定 |

### 2. メンタルヘルスKPI

| 指標 | 定義 | 目標値 | 用途 |
|------|------|--------|------|
| 平均ストレスレベル | 週次の平均（1-3） | 2.5以下 | メンタル状態の監視 |
| 平均睡眠時間 | 週次の平均（時間） | 6.5時間以上 | 生活習慣の健全性 |
| ストレス上昇トレンド | 2週連続で上昇 | なし | 面談が必要な利用者の検出 |

### 3. 訓練効果KPI

| 指標 | 定義 | 目標値 | 用途 |
|------|------|--------|------|
| 月次訓練時間 | 合計訓練時間（時間） | 60時間以上 | 訓練参加度の測定 |
| 自己評価平均 | 夕日報の自己評価平均（1-5） | 4.0以上 | 利用者の成長実感 |
| 訓練参加率 | 訓練日数 / 出席日数 × 100 | 80%以上 | 訓練プログラムへの参加度 |

### 4. 事業所運営KPI

| 指標 | 定義 | 目標値 | 用途 |
|------|------|--------|------|
| 稼働率 | 利用者数 / 定員 × 100 | 80%以上 | 事業所の収益性 |
| 継続率 | 6ヶ月継続利用者 / 全利用者 | 80%以上 | サービス満足度 |
| 就職率 | 年間就職者数 / 利用者数 | 50%以上 | 事業所の成果指標 |

---

## 📊 Looker Studio ダッシュボード設計

### ダッシュボード1: 経営管理ダッシュボード
**対象**: 施設長・管理者

**実装内容**:
- KPIカード（総利用者数、平均出席率、平均ストレス値）
- 月次出席率推移（折れ線グラフ）
- 月次平均ストレス推移（折れ線グラフ）
- 出席カテゴリ別人数（棒グラフ）
- 要支援者リスト（テーブル）

**ビジネス価値**:
- 事業所全体の健康状態を一目で把握
- トレンド分析による早期警戒
- カテゴリ別分布で支援リソース配分を最適化

---

### ダッシュボード2: 利用者詳細リスト
**対象**: スタッフ

**実装内容**:
- 全利用者の詳細データテーブル
  - ニックネーム
  - 最新出席率
  - 最新平均ストレス値
  - 出席カテゴリ
  - ストレスカテゴリ
  - 総出席日数

**ビジネス価値**:
- 全利用者の状況を一覧で確認
- ソート・フィルタによる優先支援対象の特定
- データに基づく個別支援計画の策定

---

### ダッシュボード3: 個人レポート
**対象**: 利用者本人（デモ実装）

**実装内容**:
- プルダウンリスト（利用者選択）
- スコアカード×3
  - 出席率
  - 平均ストレス値
  - 総出席日数
- （オプション）時系列推移グラフ

**ビジネス価値**:
- 利用者自身がデータを確認可能
- セルフモニタリングによる自己管理能力向上
- 目標設定と達成度の可視化

---

## 💾 サンプルデータ

### データ概要

- **利用者**: 25名（18-55歳、実務的な属性分布）
- **スタッフ**: 5名（管理者1名、スタッフ4名）
- **期間**: 2024年10月〜12月（3ヶ月）
- **出席記録**: 1,650件
- **日報**: 2,898件（朝+夕）

### データの特徴

- ✅ 個人情報保護（全て架空データ）
- ✅ 実務に即した分布
  - 出席率: 優良30% / 良好40% / 要注意20% / 要支援10%
- ✅ 相関関係を考慮
  - 睡眠不足 → ストレス増加 → 欠席率上昇
  - 訓練時間長 → 自己評価向上

### サンプルデータの生成

```bash
cd data/scripts
pip install -r requirements.txt
python generate_sample_data.py
```

詳細: [data/scripts/README.md](./data/scripts/README.md)

---

## 🚀 セットアップ

### 1. サンプルデータの生成

```bash
cd data/scripts
pip install -r requirements.txt
python generate_sample_data.py
```

### 2. BigQueryへのアップロード

詳細手順: [docs/bigquery_upload_guide.md](./docs/bigquery_upload_guide.md)

```bash
# BigQueryでデータセット作成
Dataset ID: ayumi_analytics
Location: asia-northeast1 (Tokyo)

# CSVファイルをアップロード
1. users.csv
2. staffs.csv
3. attendance_records.csv
4. daily_reports_morning.csv
5. daily_reports_evening.csv
```

### 3. dbt実装 (✅ 完了)

```bash
# ✅ dbt Cloud 開発環境設定完了
# ✅ 11モデル実装完了 (Staging 5 + Intermediate 3 + Marts 3)
# ✅ dbt test 29個全てパス
# ✅ dbt docs 生成完了
```

**実装詳細**:
- プロジェクト: `ayumi-dbt-analytics`
- データセット: `ayumi_raw` (Raw Layer)
- ロケーション: `asia-northeast1` (Tokyo)
- dbt バージョン: dbt Cloud (latest)

---

## 📂 ディレクトリ構造

```
project1-ayumi/
├── dbt/                                 # dbtプロジェクト
│   ├── models/                          # SQLモデル
│   │   ├── staging/                     # Staging層 (5モデル)
│   │   ├── intermediate/                # Intermediate層 (3モデル)
│   │   └── marts/                       # Marts層 (3モデル)
│   ├── tests/                           # カスタムテスト
│   ├── macros/                          # 再利用可能なマクロ
│   ├── dbt_project.yml                  # プロジェクト設定
│   ├── profiles.yml.example             # 接続設定サンプル
│   └── README.md                        # dbtプロジェクト説明
├── data/
│   ├── sample/                          # サンプルデータ（CSV）
│   │   ├── ayumi_users.csv
│   │   ├── ayumi_staffs.csv
│   │   ├── ayumi_attendance_records.csv
│   │   ├── ayumi_daily_reports_morning.csv
│   │   └── ayumi_daily_reports_evening.csv
│   └── scripts/                         # データ生成スクリプト
│       ├── generate_sample_data.py      # メインスクリプト
│       ├── requirements.txt             # 依存ライブラリ
│       └── README.md                    # スクリプト説明書
├── docs/                                # ドキュメント
│   ├── database_design.md               # DB設計書（ER図・テーブル定義）
│   ├── architecture.md                  # システムアーキテクチャ詳細
│   └── bigquery_upload_guide.md         # BigQueryセットアップ手順
└── README.md                            # このファイル
```

---

## 🔒 セキュリティ・コンプライアンス

### 個人情報保護

- ✅ 実名は使用しない（ニックネームのみ）
- ✅ 生年月日は年齢に変換
- ✅ 住所情報は含めない
- ✅ 監査ログで全操作を記録

### GDPR・個人情報保護法対応

- ✅ データ削除権（ソフトデリート実装）
- ✅ データポータビリティ（CSV出力機能）
- ✅ 監査ログ保持（180日間）
- ✅ 暗号化保存（機微情報）

---

## 📝 学習ポイント

このプロジェクトを通じて証明できるスキル:

1. **実務データ活用**: 現場の課題をデータで解決
2. **ETL/ELT実装**: MySQL → BigQuery の転送
3. **dbt実装**: 11モデルの実装とテスト（29テスト全てパス）
4. **ビジネスKPI設計**: 経営判断に使える指標設計
5. **可視化**: 3種類のダッシュボード設計・実装
6. **セキュリティ**: 個人情報保護・コンプライアンス対応
7. **ドメイン知識**: 福祉領域の理解

---

## 🎯 差別化要素まとめ

### なぜこのプロジェクトが評価されるか

1. **実務経験**: 現職で実際に使っているシステム
2. **希少性**: 福祉×データという組み合わせ
3. **完成度**: アプリ→DB→DWH→BIの全工程を実装完了
4. **社会性**: 障害者の就労支援という意義
5. **技術力**: セキュリティ・品質管理も実装

---

## 🔗 成果物リンク

- **GitHub Repository**: このリポジトリ
- **Looker Studio Dashboard**: [https://lookerstudio.google.com/reporting/314e9b61-8c65-4adb-92ca-2fd9a6b5e171]
- **dbt Docs**: (dbt Cloud上で生成済み)

---

## 📚 関連ドキュメント

- [データベース設計書](./docs/database_design.md)
- [システムアーキテクチャ詳細](./docs/architecture.md)
- [BigQueryアップロード手順](./docs/bigquery_upload_guide.md)
- [サンプルデータ生成スクリプト説明](./data/scripts/README.md)

---

## 📞 お問い合わせ

このプロジェクトに関するご質問は、GitHubのIssueまたはPull Requestでお願いします。

---

最終更新: 2025年11月6日