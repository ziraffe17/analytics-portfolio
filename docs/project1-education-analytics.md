# プロジェクト1: 教育データ分析基盤

## 概要
Kaggle Student Performance Datasetを使用した、エンドツーエンドのデータ分析基盤

## 目的
- データパイプライン構築スキルの証明
- dbt実装スキルの証明
- データ可視化スキルの証明

## 技術スタック
- **データソース**: Kaggle CSV
- **DWH**: Google BigQuery
- **データ変換**: dbt (data build tool)
- **可視化**: Looker Studio
- **バージョン管理**: Git/GitHub

## データフロー
```
Kaggle CSV → BigQuery Raw → dbt (Staging/Intermediate/Mart) → Looker Studio
```

## データ層設計

### Layer 1: Raw（生データ）
- **テーブル**: `raw_student_performance`
- **内容**: Kaggle CSVそのまま
- **カラム数**: 8列
- **行数**: 1000行

### Layer 2: Staging（クリーニング）

#### `stg_students`
- 学生の基本情報
- カラム: student_id, gender, race_ethnicity, parental_education

#### `stg_test_scores`
- テストスコア
- カラム: student_id, math_score, reading_score, writing_score

### Layer 3: Intermediate（中間加工）

#### `int_student_scores`
- スコアの統計計算
- 平均点、合計点、最高点

#### `int_demographics`
- 人口統計別の集約
- 性別・人種・親の学歴別

### Layer 4: Mart（分析用）

#### `mart_student_performance`
- 学生別の総合パフォーマンス
- パフォーマンス区分（高/中/低）

#### `mart_score_by_demographics`
- 属性別のスコア分析
- 性別・人種・学歴別の平均点

## 分析指標

### 1. 平均スコア分析
- 科目別平均点（数学/読解/作文）
- 性別別平均点
- 親の学歴別平均点

### 2. パフォーマンス区分
- **高得点者**: 80点以上
- **中得点者**: 60-79点
- **低得点者**: 60点未満

### 3. 相関分析
- テスト準備コースと成績の関係
- 昼食タイプと成績の関係

## 実装スコープ（Week 2-3）

### Week 2: dbt実装
- [ ] BigQueryにCSVアップロード
- [ ] dbtプロジェクト初期化
- [ ] Stagingモデル2つ実装
- [ ] Intermediateモデル2つ実装
- [ ] Martモデル2つ実装
- [ ] テスト追加
- [ ] ドキュメント生成

### Week 3: 可視化
- [ ] Looker Studio接続
- [ ] ダッシュボード作成
- [ ] README更新
- [ ] GitHub公開

## 成果物
- ✅ dbt Models（8モデル）
- ✅ SQL テストコード
- ✅ データカタログ（dbt docs）
- ✅ Looker Studio ダッシュボード
- ✅ GitHubリポジトリ

---

作成日: 2025-10-18