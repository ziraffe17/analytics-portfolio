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
├── sql/                    # SQL練習・学習記録
│   └── week1-basics/      # Week 1: SQL基礎
│       ├── task15-bigquery-basics.sql
│       ├── task16-window-functions-theory.sql
│       ├── task17-window-functions-practice.sql
│       └── README.md
├── dbt-project/           # dbtプロジェクト（Week 2-3）
│   └── ayumi-data-platform/  # PJ1: 福祉事業所データ基盤
├── data/                  # サンプルデータ
├── docs/                  # ドキュメント・画像
└── README.md
```

## 🎯 学習ロードマップ

### Week 0-1: SQL基礎・応用
- ✅ BigQuery環境構築
- ✅ BigQueryとMySQLの違い理解
- ✅ ウィンドウ関数（ROW_NUMBER, RANK, LAG, LEAD）
- ⏳ CTE、サブクエリ
- ⏳ LeetCode SQL問題演習

### Week 2: dbt実装（PJ1）
- ⏳ dbt Cloud環境構築
- ⏳ あゆみデータ基盤構築
- ⏳ staging/intermediate/marts層の実装
- ⏳ データ品質テスト

### Week 3: データ可視化・PJ2
- ⏳ 教育データ分析プロジェクト
- ⏳ Looker Studioダッシュボード作成
- ⏳ Jupyter Notebookでの分析

### Week 4: ポートフォリオ・書類作成
- ⏳ GitHub Pagesでポートフォリオサイト公開
- ⏳ 職務経歴書・履歴書作成
- ⏳ 技術ブログ執筆

## 📚 主要プロジェクト

### プロジェクト1: あゆみデータ基盤（計画中）
福祉事業所向けSaaSのデータ基盤構築

**技術:**
- MySQL → BigQuery連携
- dbt（staging/intermediate/marts）
- Looker Studio

**成果物:**
- 出席トレンド分析
- プログラム効果測定
- 支援計画進捗管理

### プロジェクト2: 教育→就労分析（計画中）
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

## 💡 学習の記録

### Task15: BigQueryで簡単なクエリ実行
- 基本的なSELECT、WHERE、GROUP BY
- 公開データセット（usa_names）の活用
- **学び**: データの粒度に注意（州ごとのデータ）

### Task16: ウィンドウ関数基礎理論
- ROW_NUMBER, RANK, DENSE_RANK
- LAG, LEAD
- 累積合計、移動平均

### Task17: ウィンドウ関数基礎実践
- BigQueryで実際のデータ分析
- トップ5の名前の推移分析
- **学び**: GROUP BYで集計してからウィンドウ関数

### 完了済みタスク
- Task01-13: 環境構築・基礎学習
- Task14: MySQLとBigQueryの違い理解
- Task15: BigQuery基本クエリ
- Task16: ウィンドウ関数理論
- Task17: ウィンドウ関数実践

## 🔗 関連リンク

- **Google Cloud Project**: mystic-now-474722-r4
- **dbt Cloud**: （準備中）
- **ポートフォリオサイト**: （準備中）
- **技術ブログ**: （準備中）

## 📫 連絡先

準備中

---

**最終更新**: 2025年10月15日  
**進捗**: Week 1 - SQL基礎学習中