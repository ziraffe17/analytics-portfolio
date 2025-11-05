# Data Analytics Portfolio

データアナリスト転職に向けた学習ポートフォリオ

## 📊 プロジェクト概要

このリポジトリは、データアナリストとしてのスキルを示すポートフォリオです。
8週間の集中学習を通じて、SQL・dbt・データ可視化の実務スキルを習得しました。

## 🛠️ 技術スタック

- **データベース**: Google BigQuery
- **SQL**: 標準SQL、ウィンドウ関数、CTE、サブクエリ
- **データ変換**: dbt (data build tool)
- **データ可視化**: Looker Studio
- **バージョン管理**: Git/GitHub
- **開発環境**: VSCode

## 📁 プロジェクト構成
```
analytics-portfolio/
├── sql/                       # SQL練習・学習記録
│   ├── week1-basics/         # Week 1: SQL基礎
│   └── week1-leetcode/       # Week 1: LeetCode SQL問題
├── project1-ayumi/           # プロジェクト1: 就労支援SaaSデータ基盤
│   ├── dbt/                  # dbtプロジェクト
│   │   ├── models/           # SQLモデル（staging/intermediate/marts）
│   │   ├── tests/            # データ品質テスト
│   │   ├── dbt_project.yml   # dbt設定
│   │   └── README.md
│   ├── data/                 # サンプルデータ・生成スクリプト
│   ├── docs/                 # ドキュメント（DB設計書など）
│   └── README.md
├── project2-education/        # プロジェクト2: 教育データ分析（計画中）
├── notebooks/                # Jupyter Notebook分析
├── data/                     # 共通サンプルデータ
├── docs/                     # 共通ドキュメント
├── images/                   # 画像ファイル
└── README.md
```

## 🎯 学習ロードマップ

### Week 0-1: SQL基礎・応用
- ✅ BigQuery環境構築
- ✅ BigQueryとMySQLの違い理解
- ✅ ウィンドウ関数（ROW_NUMBER, RANK, LAG, LEAD）
- ✅ CTE、サブクエリ
- ✅ LeetCode SQL問題演習（Task19-40完了）

### Week 2-3: プロジェクト1 - あゆみデータ基盤
- ✅ データベース設計
- ✅ サンプルデータ生成スクリプト作成
- ✅ BigQueryへのデータアップロード
- ✅ dbt Cloud環境構築
- ✅ staging/intermediate/marts層の実装
- ⏳ データ品質テスト
- ⏳ Looker Studioダッシュボード作成

### Week 4: プロジェクト2 - 教育データ分析
- ⏳ Kaggle教育データ取得
- ⏳ BigQueryへのデータ取り込み
- ⏳ dbt実装
- ⏳ Jupyter Notebookでの分析
- ⏳ Looker Studioダッシュボード作成

### Week 5-6: ポートフォリオ・書類作成
- ⏳ GitHub Pagesでポートフォリオサイト公開
- ⏳ 職務経歴書・履歴書作成
- ⏳ 技術ブログ執筆
- ⏳ 応募準備

## 📚 主要プロジェクト

### プロジェクト1: 就労支援SaaS データ分析基盤

**福祉×データという差別化された専門性を証明するプロジェクト**

#### 概要
就労移行支援事業所向けSaaS『あゆみ』の運用データを活用し、データドリブンな支援の質向上と経営判断の可視化を実現。

#### 技術スタック
- **Application**: Laravel (PHP)
- **DB**: MySQL → BigQuery
- **Transformation**: dbt
- **Visualization**: Looker Studio

#### 差別化ポイント
- ✅ 実務経験に基づく設計（現職での課題解決）
- ✅ 福祉×データという希少な組み合わせ
- ✅ セキュリティ・コンプライアンス対応（GDPR、監査ログ）
- ✅ アプリケーションDB → DWH の全工程実装

#### 主要KPI
- 月次出席率: 90%以上
- 平均ストレスレベル: 2.5以下
- 月次訓練時間: 60時間以上
- 事業所稼働率: 80%以上

#### リンク
- 📂 [プロジェクト詳細](./project1-ayumi/)
- 🗂️ [データベース設計書](./project1-ayumi/docs/database_design.md)
- 🚀 [BigQueryセットアップ手順](./project1-ayumi/data/sample/BIGQUERY_UPLOAD_GUIDE.md)
- 🐍 [サンプルデータ生成スクリプト](./project1-ayumi/data/scripts/)
- 📊 [Looker Studioダッシュボード](https://lookerstudio.google.com/reporting/314e9b61-8c65-4adb-92ca-2fd9a6b5e171)

---

### プロジェクト2: 教育データ分析（計画中）
教育から就労への移行成功要因分析

**技術:**
- Kaggle教育データ
- BigQuery + dbt
- Jupyter Notebook
- Looker Studio

**成果物:**
- 相関分析
- 地域格差分析
- 成功要因の特定

**リンク:**
- [プロジェクト詳細](./project2-education/)

---

## 💡 学習の記録

### Week 0: 環境構築
- ✅ Task01-13: Google Cloud環境構築、BigQuery基礎
- ✅ Task14: MySQLとBigQueryの違い理解

### Week 1: SQL基礎・応用
- ✅ Task15: BigQuery基本クエリ（SELECT、WHERE、GROUP BY）
- ✅ Task16: ウィンドウ関数理論（ROW_NUMBER, RANK, LAG, LEAD）
- ✅ Task17: ウィンドウ関数実践（usa_namesデータ分析）
- ✅ Task18: CTE・サブクエリ
- ✅ Task19-40: LeetCode SQL問題演習（22問完了）

### Week 2: プロジェクト1 準備・実装
- ✅ Task41: データベース設計書作成
- ✅ Task42: サンプルデータ生成スクリプト作成
- ✅ Task43: BigQueryセットアップ
- ✅ Task44: dbtモデル実装（staging/intermediate/marts）
- ✅ Task45: Looker Studioダッシュボード作成

### 主な学び
- データの粒度に注意（集計レベルの理解）
- ウィンドウ関数は集計後に適用
- CTEで複雑なクエリを読みやすく構造化
- 実務データの設計とサンプルデータ生成の重要性

## 🔗 関連リンク

- **Google Cloud Project**: mystic-now-474722-r4
- **dbt Cloud**: （準備中）
- **ポートフォリオサイト**: （準備中）
- **技術ブログ**: （準備中）

## 📫 連絡先

準備中

---

**最終更新**: 2025年11月5日
**進捗**: Week 2 - プロジェクト2（あゆみデータ基盤）準備完了、dbt実装フェーズへ